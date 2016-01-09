require 'rest-client'
require 'json'

class BaseService

  # Lazy enumerator of all paginated results.
  # Works for both paginated and non-paginated resources.
  def self.get_all(resource, query_options={})
    query_options = query_options.clone
    query_options[:page] = 1
    query_options[:per_page] = 100
    Enumerator.new do |enumerator|
      loop do
        results, next_page = get_page(resource, query_options)
        results.each { |record| enumerator.yield record }
        raise StopIteration unless next_page
        query_options[:page] += 1
      end
    end
  end

  def self.find_by_field(resource, field, value)
    matching = BaseService.get_all(resource).lazy.select { |resource| resource[field] == value }.to_a
    if matching.size == 0
      raise KeyError.new("No #{resource} found by #{field} #{value}")
    elsif matching.size > 1
      raise KeyError.new("Multiple #{resource} found by #{field} #{value} (found #{matching.size})")
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

  def self.get_page(resource, query_options)
    headers = auth_headers.clone
    headers[:params] = query_options
    response = RestClient.get "#{host}/api/v1/#{resource}.json", headers
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
