desc "Lists the currently configured service times"
task :list_service_times do

  query_options = {}
  campus = ENV["CAMPUS_NAME"]
  campus_service_times = ServiceTimeService.get_all(query_options).lazy
            .select { |st| not campus or campus == st["campus"]["slug"] }
  puts "campus service times (all): #{JSON.pretty_generate(campus_service_times.to_a)}"
  regular_campus_service_times = campus_service_times.lazy.select { |st| not st["event"] }
  puts "campus service times (no events): #{JSON.pretty_generate(regular_campus_service_times.to_a)}"

  time_of_day_wanted = ENV["TIME_OF_DAY_WANTED"].split(',')
  time_to_service_time = ServiceTimeService.find_by_hh_mm(time_of_day_wanted, query_options, campus)
  puts "found: #{time_to_service_time}"

end
