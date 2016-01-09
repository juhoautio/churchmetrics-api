desc "Collects statistics about service date times of the stored records"
task :analyze_record_service_times do

  campus_id = CampusService.find_by_name(ENV["CAMPUS_NAME"])["id"]
  query_options = {
      :campus_id => campus_id
  }
  split_by_category = false

  campuses = {}

  count = 0
  RecordService.get_all(query_options).each do |record|

    count += 1
    if count % 100 == 0
      puts "processed #{count} records.."
    end

    campus = record["campus"]
    event = record["event"]
    category = record["category"]
    service_date_time = record["service_date_time"]
    service_timezone = record["service_timezone"]

    time = ServiceTimeService.time_in_hh_mm_with_offset(service_date_time, service_timezone)
    time ||= "Mid-Week Giving"
    time += " " + event["name"] if event

    date_time = ServiceTimeService.date_time_with_offset(service_date_time, service_timezone)

    categories = campuses[campus["slug"]] ||= {}
    service_date_times = split_by_category ? categories[category["name"]] ||= {} : categories
    stats = service_date_times[time] ||= {}
    stats["count"] ||= 0
    stats["count"] += 1
    if date_time
      stats["oldest"] = date_time.strftime('%Y-%m-%d') unless stats["oldest"] and stats["oldest"] < date_time
      stats["newest"] = date_time.strftime('%Y-%m-%d') unless stats["newest"] and stats["newest"] > date_time
    else
      # Mid-Week Giving
      week_reference = record["week_reference"]
      stats["oldest"] = week_reference unless stats["oldest"] and stats["oldest"] < week_reference
      stats["newest"] = week_reference unless stats["newest"] and stats["newest"] > week_reference
    end

  end

  json = JSON.pretty_generate(campuses)
  puts json
  File.open('tmp/analyze_record_service_times.json', 'w') { |f| f.write(json) }
  puts "Processed total #{count} records"

end
