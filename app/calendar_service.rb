require 'time'
require 'yaml'

class CalendarService

  # 9時間
  NINE_HOUR = Rational(3, 8)

  def initialize
    settings = YAML.load_file '../setting.yaml'
    @start_time = Time.parse settings['start_time']
    @end_time = Time.parse settings['end_time']
    @interval_time = Time.parse settings['interval_time']

  end

  def calculate_free_time(calendar_id_list, free_busy_calender)

    free_time = []
    previous_datetime = nil

    calendar_id_list.each do |calendar_id|
      free_busy_calender.calendars[calendar_id].busy.each do |busy_time|
        start_jst = busy_time.start + NINE_HOUR
        end_jst = busy_time.end + NINE_HOUR

        if previous_datetime.nil?
          previous_datetime = DateTime.new(start_jst.year,
                                           start_jst.month,
                                           start_jst.day,
                                           @start_time.hour,
                                           @start_time.min,
                                           0,
                                           0,
                                           0)
        end

        interval = (start_jst.hour - previous_datetime.hour) * 60
        interval += start_jst.min - previous_datetime.min

        if interval >= @interval_time.min
          free_time << { start_time: previous_datetime, end_time: start_jst }
        end
        previous_datetime = end_jst
      end
    end
    free_time
  end
end