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

  ##
  # Google Calendar APIで取得したFreeBusyを元に空き時間を取得します。
  # @param calendar_id_list カレンダーIDのリスト
  # @param free_busy_calender Google Calendar APIを使用して取得したFreeBusy
  def calc_free_time(calendar_id_list, free_busy_calender)

    free_time = []
    previous_datetime = nil

    calendar_id_list.each do |calendar_id|
      free_busy_calender.calendars[calendar_id].busy.each do |busy_time|
        start_jst = busy_time.start + NINE_HOUR
        end_jst = busy_time.end + NINE_HOUR

        if previous_datetime.nil?
          previous_datetime = DateTime.new start_jst.year, start_jst.month,
                                           start_jst.day, @start_time.hour
        end

        if calc_interval(previous_datetime, start_jst) >= @interval_time.min
          free_time << { start_time: previous_datetime, end_time: start_jst }
        end
        previous_datetime = end_jst
      end
    end
    free_time
  end

  ##
  # 二つのDateTimeを受け取り，その間時間を計算します。
  # @param from 開始時間
  # @param to 終了時間
  #
  # @return 間時間
  def calc_interval(from, to)
    interval = (to.hour - from.hour) * 60
    interval += to.min - from.min

    # @type Integer
    interval
  end
end