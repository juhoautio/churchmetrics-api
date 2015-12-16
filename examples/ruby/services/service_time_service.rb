require_relative 'base_service'

class ServiceTimeService < BaseService

  def self.get_all(query_options={})
    # TODO handle as paginated, because this is
    BaseService.get_all("service_times", query_options)
  end

  def self.get_ids(time_of_day_wanted, query_options={})
    time_to_service_time_id = {}
    service_times = get_all query_options
    service_times = service_times.select { |st| not st["event"] }
    service_times.each do |st|
      time_of_day = time_in_hh_mm(st["time_of_day"])
      time_of_day_wanted.each do |wanted|
        if wanted == time_of_day
          raise KeyError.new("Multiple service times found for #{wanted}") if time_to_service_time_id.has_key? wanted
          time_to_service_time_id[wanted] = st["id"]
        end
      end
    end
    check_ids(time_to_service_time_id, time_of_day_wanted)
    time_to_service_time_id
  end

  def self.time_in_hh_mm(time)
    Time.parse(time).strftime("%H:%M") if time
  end

  private

  def self.check_ids(time_to_service_time_id, time_of_day_wanted)
    time_of_day_wanted.each do |wanted|
      raise KeyError.new("No service time found for #{wanted}") if not time_to_service_time_id[wanted]
    end
  end

end