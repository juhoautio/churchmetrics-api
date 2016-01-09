require 'active_support/time'
require 'colorize'
require 'thread/pool'
require 'thread/future'

desc "Adjusts service date times of old records to match with currently configured service times"
task :adjust_record_service_times do

  setup_log

  campus = ENV["CAMPUS_NAME"]
  campus_id = CampusService.find_by_name(campus)["id"]
  query_options = {:campus_id => campus_id}
  # old time => current service time
  mappings = ENV["SERVICE_TIME_MAPPINGS"].split(',').map { |entry| entry.split('->') }.to_h
  run(query_options, mappings, campus, dry_run=true)

end

private

def run(query_options={}, mappings, campus, dry_run)
  pool = Thread.pool(10)
  time_to_service_time = ServiceTimeService.find_by_hh_mm(mappings.values.to_set, query_options, campus)
  processed = 0
  modified = 0
  failed = 0
  futures = []
  RecordService.get_all(query_options).each do |record|
    processed += 1
    original_date = record["service_date_time"]
    original_tz = record["service_timezone"]
    mappings.each do |from, to|
      # TODO include event service times and handle them
      if not record["event"] and ServiceTimeService.time_in_hh_mm_with_offset(original_date, original_tz) == from
        service_time = time_to_service_time[to]
        new_date_time = ServiceTimeService.fix_service_time(original_date, original_tz, service_time)
        puts "New date time: #{new_date_time} <- #{original_date}"
        fields = {"service_time_id" => service_time["id"],
                  "service_date_time" => new_date_time}
        log(record, fields)
        f = pool.future {
          begin
            RecordService.update(record["id"], fields) unless dry_run
            write(record, "successful")
            puts "Edited #{from} -> #{to} for #{record["category"]["name"]}: #{record["value"]}".green
            modified += 1
          rescue RestClient::UnprocessableEntity => e
            write(record, "errors")
            puts "Couldn't update record with id #{record["id"]} - maybe there's also a record with the correct service time for the same day?".red
            failed += 1
          end
        }
        futures += [f]
      end
    end
  end
  # wait for tasks to complete
  futures.each do |f|
    ~f
  end
  puts "Processed total #{processed} records. Adjusted times for #{modified} records. Failed to adjust #{failed} records"

end

def setup_log
  @log_dir = "tmp/adjust_record_service_times/#{ENV["EMAIL"]}"
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
  File.open("#{@log_dir}/records-#{identifier}.tsv", 'a') do |file|
    file.puts("#{record["service_date_time"]}\t#{record["category"]["name"]}\t#{record["value"]}")
  end
end
