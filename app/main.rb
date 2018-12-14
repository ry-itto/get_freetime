require 'date'
require 'yaml'
require_relative 'calendar'
require_relative 'calendar_service'

calendar = Calendar.instance

calendar_id_list = YAML.load_file '../calendar_ids.yaml'

free_busy = calendar.fetch_free_busy(calendar_id_list,
                                     DateTime.new(2018, 12, 3, 0, 0, 0, 0, 0),
                                     DateTime.new(2018, 12, 4, 0, 0, 0, 0, 0))

service = CalendarService.new
service.calculate_free_time(calendar_id_list, free_busy).each do |free_time|
  puts "start : #{free_time[:start_time]}, end : #{free_time[:end_time]}"
end