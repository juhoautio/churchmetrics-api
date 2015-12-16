require 'rest-client'
require 'json'

class BaseService

  def self.get_all(resource, query_options={})
    headers = auth_headers.clone
    headers[:params] = query_options
    response = RestClient.get "#{host}/api/v1/#{resource}.json", headers
    JSON(response.body)
  end

  def self.find_by_field(resource, field, value)
    matching = get_all(resource).select{ |resource| resource[field] == value }
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

end
