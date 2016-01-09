require_relative 'base_service'

class UserService < BaseService

  def self.resource_name
    "users"
  end

  def self.name_field
    "name"
  end

end
