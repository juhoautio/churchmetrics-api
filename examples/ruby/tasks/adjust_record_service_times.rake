require_relative '../services/campus_service'
require_relative '../services/category_service'
require_relative '../services/record_service'
require_relative '../services/service_time_service'

desc "Adjusts service date times of old records to match with currently configured service times"
task :adjust_record_service_times do

  setup_log

  campus_id = CampusService.find_by_name(ENV["CAMPUS_NAME"])["id"]
  query_options = {:campus_id => campus_id}
  mappings = {"09:30" => "10:00", "11:30" => "12:00"}
  run(query_options, mappings, dry_run=true)

end

private

def run(query_options={}, mappings, dry_run)

  time_to_service_time_id = ServiceTimeService.get_ids(mappings.values, query_options)

  RecordService.get_all(query_options).each do |record|
    original_date = record["service_date_time"]
    mappings.each do |from, to|
      if ServiceTimeService.time_in_hh_mm(original_date) == from
        fields = {"service_time_id" => time_to_service_time_id[to],
                  "service_date_time" => original_date.gsub(from, to)}
        log(record, fields)
        RecordService.update(record["id"], fields) unless dry_run
        puts "Edited #{from} -> #{to} for #{record["category"]["name"]}: #{record["value"]}"
      end
    end
  end

end

def setup_log
  @log_dir = "tmp/adjust_record_service_times"
  rm_r @log_dir if File.exist? @log_dir
  mkdir_p @log_dir
end

def log(record, fields)
  write(record, "original")
  write(record.merge(fields), "modified")
end

def write(record, identifier)
  File.open("#{@log_dir}/records-#{identifier}.json.txt", 'a') do |file|
    file.puts(JSON.pretty_generate(record))
  end
end
