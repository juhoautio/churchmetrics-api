require_relative 'base_service'

class RecordService < BaseService

  def self.get_all(query_options={})
    BaseService.get_all("records", query_options)
  end

  def self.update(id, fields)
    headers = auth_headers.clone
    headers["Content-Type"] = "application/json"
    puts "PUT records/#{id}: #{fields.to_json}"
    response = RestClient.put "#{host}/api/v1/records/#{id}.json", fields.to_json, headers
    puts "after update: #{response.code}"
  end

  def self.delete(id)
    RestClient.delete "#{host}/api/v1/records/#{id}.json", auth_headers
  end

end
