require_relative 'base_service'

class CampusService < BaseService

  def self.resource_name
    "campuses"
  end

  def self.name_field
    "slug"
  end

end