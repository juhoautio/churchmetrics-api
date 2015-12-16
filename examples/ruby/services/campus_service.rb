require_relative 'base_service'

class CampusService < BaseService

  def self.find_by_name(name)
    find_by_field "campuses", "slug", name
  end

  # def self.get_all
  #   get_all "campuses"
  # end

end