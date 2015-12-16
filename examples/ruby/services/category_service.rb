require_relative 'base_service'

class CategoryService < BaseService

  def self.find_by_name(name)
    find_by_field "categories", "name", name
  end

  # def self.get_all
  # end

end