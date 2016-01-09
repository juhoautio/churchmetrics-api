desc "Lists service date times of records"
task :list_record_service_times do

  campus_id = CampusService.find_by_name(ENV["CAMPUS_NAME"])["id"]
  category_id = CategoryService.find_by_name(ENV["CATEGORY_NAME"])["id"]
  query_options = {
      :category_id => category_id,
      :campus_id => campus_id
  }

  # just print the current values
  RecordService.get_all(query_options).each do |record|
    puts "#{record["service_date_time"]} [#{record["service_timezone"]}]
        -> #{ServiceTimeService.time_in_hh_mm_with_offset(record["service_date_time"], record["service_timezone"])}
#{record["category"]["name"]}: #{record["value"]}"
  end

end
