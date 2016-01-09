require_relative 'base_service'

class ServiceTimeService < BaseService

  def self.get_all(query_options={}, campus=nil)
    BaseService.get_all("service_times", query_options).lazy.select { |st| not campus or campus == st["campus"]["slug"] }
  end

  # find service time objects for a set of time of day values (HH:MM)
  # excludes event service times
  def self.find_by_hh_mm(time_of_day_wanted, query_options={}, campus=nil)
    time_to_service_time = {}
    service_times = get_all query_options, campus
    service_times = service_times.lazy.select { |st| not st["event"] }
    service_times.each do |st|
      time_of_day = time_in_hh_mm(st["time_of_day"])
      time_of_day_wanted.each do |wanted|
        if wanted == time_of_day
          raise KeyError.new("Multiple service times found for #{wanted}") if time_to_service_time.has_key? wanted
          time_to_service_time[wanted] = st
        end
      end
    end
    check_ids(time_to_service_time, time_of_day_wanted)
    time_to_service_time
  end

  def self.time_in_hh_mm(datetime)
    Time.parse(datetime).strftime('%H:%M') if datetime
  end

  def self.time_in_hh_mm_with_offset(datetime, timezone)
    if datetime
      with_offset = date_time_with_offset(datetime, timezone)
      with_offset.strftime('%H:%M')
    end
  end

  def self.date_time_with_offset(datetime, timezone)
    if datetime
      parsed = Time.parse(datetime).try(:utc)
      parsed.in_time_zone(timezone)
    end
  end

  # takes hh:mm & applies timezone offset from service_time, day from original_date
  def self.fix_service_time(original_date, original_tz, service_time)
    day = ServiceTimeService.date_time_with_offset(original_date, original_tz)
    time_of_day = Time.parse(service_time["time_of_day"]).try(:utc)
    service_time_with_offset(time_of_day, day, service_time["timezone"]).iso8601(3)
  end

  private

  def self.service_time_with_offset(time_of_day, day, timezone)
    Time.new(day.year, day.month, day.mday, time_of_day.hour, time_of_day.min, nil,
             time_zone_offset(timezone, day, time_of_day)).utc
  end

  # Timezone offset needs a date because of daylight savings
  def self.time_zone_offset(timezone, day, time_of_day)
    Time.new(day.year, day.month, day.mday,
             time_of_day.hour, time_of_day.min).in_time_zone(timezone).formatted_offset
  end

  def self.check_ids(time_to_service_time_id, time_of_day_wanted)
    time_of_day_wanted.each do |wanted|
      raise KeyError.new("No service time found for #{wanted}") if not time_to_service_time_id[wanted]
    end
  end

end
