desc "Lists the currently configured service times"
task :list_service_times do

  query_options = {}
  campus = ENV["CAMPUS_NAME"]
  all = ServiceTimeService.get_all(query_options, campus)
  puts "service_times (all): #{JSON.pretty_generate(all.to_a)}"
  service_times = all.lazy.select { |st| not st["event"] }
  puts "service_times (no events): #{JSON.pretty_generate(service_times.to_a)}"

  time_of_day_wanted = ENV["TIME_OF_DAY_WANTED"].split(',')
  time_to_service_time = ServiceTimeService.find_by_hh_mm(time_of_day_wanted, query_options, campus)
  puts "found: #{time_to_service_time}"

end
