require_relative 'base_service'

class CategoryService < BaseService

  def self.resource_name
    "categories"
  end

  def self.name_field
    "name"
  end

end