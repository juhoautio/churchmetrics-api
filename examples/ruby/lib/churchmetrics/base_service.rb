require 'rest-client'
require 'json'

class BaseService

  def self.resource_name
    fail NotImplementedError, "A service class must implement #resource_name"
  end

  def self.name_field
    fail NotImplementedError, "A service class must implement #name_field"
  end

  # Lazy enumerator of all paginated results.
  # Works for both paginated and non-paginated resources.
  def self.get_all(query_options={})
    query_options = query_options.clone
    query_options[:page] = 1
    query_options[:per_page] = 100
    Enumerator.new do |enumerator|
      loop do
        results, next_page = get_page(query_options)
        results.each { |record| enumerator.yield record }
        raise StopIteration unless next_page
        query_options[:page] += 1
      end
    end
  end

  # TODO create / POST

  def self.update(id, fields)
    headers = auth_headers.clone
    headers["Content-Type"] = "application/json"
    puts "PUT #{self.resource_name}/#{id}: #{fields.to_json}"
    response = RestClient.put "#{host}/api/v1/#{self.resource_name}/#{id}.json", fields.to_json, headers
    puts "update response code: #{response.code}"
  end

  def self.delete(id)
    RestClient.delete "#{host}/api/v1/#{self.resource_name}/#{id}.json", auth_headers
  end

  def self.find_by_name(name)
    find_by_field self.name_field, name
  end

  def self.find_by_field(field, value)
    matching = self.get_all().lazy.select { |resource| resource[field] == value }.to_a
    if matching.size == 0
      raise KeyError.new("No #{self.resource_name} found by #{field} #{value}")
    elsif matching.size > 1
      raise KeyError.new("Multiple #{self.resource_name} found by #{field} #{value} (found #{matching.size})")
    end
    matching.first
  end

  def self.auth_headers
    {"X-Auth-User" => email, "X-Auth-Key" => api_key}
  end

  def self.host
    ENV["API_HOST"]
  end

  def self.email
    ENV["EMAIL"]
  end

  def self.api_key
    ENV["API_KEY"]
  end

  private

  def self.get_page(query_options)
    headers = auth_headers.clone
    headers[:params] = query_options
    response = RestClient.get "#{host}/api/v1/#{self.resource_name}.json", headers
    next_page = get_next_page_link(response.headers)
    [JSON(response.body), next_page]
  end

  def self.get_next_page_link(headers)
    link_header = headers[:link]
    if link_header
      link_text_array = link_header.split(",")
      links = link_text_array.map { |link| link.split("; ") }
      next_page = links.lazy.select { |link| link[1] == "rel='next'" }.first
    end
    next_page
  end

end
