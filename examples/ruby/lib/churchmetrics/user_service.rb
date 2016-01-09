require_relative 'base_service'

class UserService < BaseService

  def self.get_all(query_options={})
    BaseService.get_all("users", query_options)
  end

  def self.find_by_name(name)
    find_by_field "users", "name", name
  end

end
