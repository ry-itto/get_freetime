require 'yaml'
require 'date'
require_relative 'calender'

calendar = Calender.new
calendar_id_list = YAML.load_file '../calendar_ids.yaml'

free_busy = calendar.fetch_free_busy(calendar_id_list,
                                     DateTime.new(2018, 12, 03, 0, 0, 0, 0, 0),
                                     DateTime.new(2018, 12, 04, 0, 0, 0, 0, 0))
calendar_id_list.each do |calendar_id|
  free_busy.calendars[calendar_id].busy.each do |free_time|
    puts "start: #{free_time.start}, end: #{free_time.end}"
  end
end