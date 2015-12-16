require_relative '../services/campus_service'
require_relative '../services/category_service'
require_relative '../services/record_service'
require_relative '../services/service_time_service'

desc "Lists the currently configured service times"
task :list_service_times do

  campus_id = CampusService.find_by_name(ENV["CAMPUS_NAME"])["id"]

  query_options = {:campus_id => campus_id}
  time_of_day_wanted = ["17:00", "18:30"]

  all = ServiceTimeService.get_all(query_options)
  service_times = all.select { |st| not st["event"] }

  puts "service_times (no events): #{service_times}"

  time_to_service_time_id = ServiceTimeService.get_ids(time_of_day_wanted, query_options)

  puts "found: #{time_to_service_time_id}"

end
