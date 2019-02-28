require_relative '../google_calendar/calendar_fetcher'
require 'time'
require 'yaml'

##
# カレンダー関係の処理を行うクラス
class CalendarService

  # 9時間
  NINE_HOUR = Rational(3, 8)

  def initialize(start_date, end_date, start_time, end_time, interval_time)
    @start_time = Time.parse start_time
    @end_time = Time.parse end_time
    @interval_time = Time.parse interval_time
    @start_date = Date.parse start_date
    @end_date = Date.parse end_date
  end

  ##
  # Google Calendar APIで取得したFreeBusyを元に空き時間を取得します。
  # @param calendar_id_list カレンダーIDのリスト
  #
  def calc_free_time(calendar_id_list = fetch_all_calendar_ids)

    free_time = []
    previous_datetime = nil

    calendar_id_list.each do |calendar_id|
      fetch_free_time(calendar_id_list).calendars[calendar_id].busy.each do |busy_time|
        start_jst = busy_time.start + NINE_HOUR
        end_jst = busy_time.end + NINE_HOUR

        previous_datetime ||= DateTime.new start_jst.year, start_jst.month,
                                           start_jst.day, @start_time.hour

        if calc_interval(previous_datetime, start_jst) >= @interval_time.min
          free_time << { start_time: previous_datetime, end_time: start_jst }
        end
        previous_datetime = end_jst
      end
    end

    complete_free_days free_time
  end

  private

  ##
  # カレンダーIDのリストを受け取り，FreeBusyを取得します。
  # @param calendar_id_list カレンダーIDのリスト
  #
  # @return Google CalendarFetcher APIを使用して取得したFreeBusy
  #
  def fetch_free_time(calendar_id_list)
    calendar = CalendarFetcher.instance
    calendar.fetch_free_busy(calendar_id_list,
                             @start_date.to_datetime,
                             @end_date.to_datetime)
  end

  ##
  # 二つのDateTimeを受け取り，その間時間を計算します。
  # @param from 開始時間
  # @param to 終了時間
  #
  # @return 間時間
  #
  def calc_interval(from, to)
    interval = (to.hour - from.hour) * 60
    interval += to.min - from.min

    # @type Integer
    interval
  end

  ##
  # 指定した日付間に丸一日空いている日があった場合に補完し，ソートします。
  #
  def complete_free_days(free_time)
    target_dates = @start_date.upto(@end_date).to_a

    uniq_array = free_time.map { |time| time[:start_time].to_date }.uniq
    target_dates.each do |date|
      next if uniq_array.include? date

      start_time = DateTime.new date.year, date.month,
                                date.day, @start_time.hour
      end_time = DateTime.new date.year, date.month,
                              date.day, @end_time.hour
      free_time << { start_time: start_time, end_time: end_time }
    end

    free_time.sort_by { |time| time[:start_time] }
  end

  ##
  # アカウントに紐づく全てのCalendarIdを取得します。
  #
  def fetch_all_calendar_ids
    calendars = CalendarFetcher.instance.fetch_calender_list.items
    calendars.map { |c| c.id }
  end
end