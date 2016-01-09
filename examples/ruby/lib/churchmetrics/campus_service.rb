require_relative 'base_service'

class CampusService < BaseService

  def self.get_all(query_options={})
    BaseService.get_all("campuses", query_options)
  end

  def self.find_by_name(name)
    find_by_field "campuses", "slug", name
  end

end