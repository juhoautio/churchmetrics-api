require_relative 'base_service'

class CategoryService < BaseService

  def self.get_all(query_options={})
    BaseService.get_all("categories", query_options)
  end

  def self.find_by_name(name)
    find_by_field "categories", "name", name
  end

end