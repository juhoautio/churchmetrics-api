require_relative 'base_service'

class RecordService < BaseService

  def self.update(id, fields)
    headers = auth_headers.clone
    headers["Content-Type"] = "application/json"
    puts "payload: #{fields.to_json}"
    response = RestClient.put "#{host}/api/v1/records/#{id}.json", fields.to_json, headers
    puts "after update: #{response.code}"
  end

  # lazy enumerator of all paginated results
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

  def self.get_page(query_options)
    headers = auth_headers.clone
    headers[:params] = query_options
    response = RestClient.get "#{host}/api/v1/records.json", headers
    # puts "response headers:" + response.headers.to_s
    next_page = get_next_page_link(response.headers)
    [JSON(response.body), next_page]
  end

  def self.get_next_page_link(headers)
    link_header = headers[:link]
    if link_header
      link_text_array = link_header.split(",")
      links = link_text_array.map { |link| link.split("; ") }
      next_page = links.select { |link| link[1] == "rel='next'" }.first
    end
    next_page
  end

end
