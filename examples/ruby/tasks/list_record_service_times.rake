require_relative '../services/campus_service'
require_relative '../services/category_service'
require_relative '../services/record_service'
require_relative '../services/service_time_service'

desc "Lists service date times of records"
task :list_record_service_times do

  campus_id = CampusService.find_by_name(ENV["CAMPUS_NAME"])["id"]
  category_id = CategoryService.find_by_name('Total attendance')["id"]
  query_options = {
      :category_id => category_id,
      :campus_id => campus_id
  }

  # just print the current values
  RecordService.get_all(query_options).each do |record|
    puts "#{record["service_date_time"]} #{record["category"]["name"]}: #{record["value"]}"
  end

end
