require 'date'
require 'yaml'
require_relative 'calendar'
require_relative 'calendar_service'

calendar_id_list = YAML.load_file '../calendar_ids.yaml'

service = CalendarService.new
service.calc_free_time(calendar_id_list).each do |free_time|
  puts "start : #{free_time[:start_time]}, end : #{free_time[:end_time]}"
end