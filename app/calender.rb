require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'

class Calender
  APPLICATION_NAME = '空き時間出力'.freeze
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  CREDENTIALS_PATH = '../credentials.json'.freeze
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  def initialize
    @calendar_service = Google::Apis::CalendarV3::CalendarService.new
    @calendar_service.client_options.application_name = APPLICATION_NAME
    @calendar_service.authorization = authorize
  end

  ##
  # API使用時に認証します。
  #
  # @return 認証情報
  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
    authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url base_url: OOB_URI
      puts '以下のURLにアクセスして，ユーザでログインし，認証してください。' \
          'そして，その結果出てきたコードを入力して ください。' + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id,
                                                                   code: code,
                                                                   base_url: OOB_URI)
    end
    credentials
  end

  ##
  # APIを使用するGoogleアカウントに紐づいているカレンダーのリストを取得します。
  # API reference : https://developers.google.com/calendar/v3/reference/calendarList/list
  #
  # @return カレンダーのリスト
  def fetch_calender_list
    @calendar_service.list_calendar_lists
  end

  ##
  # カレンダーIDからカレンダーに紐づくイベントのリストを取得します。
  # API reference : https://developers.google.com/calendar/v3/reference/events/list
  # @param calender_id カレンダーID
  #
  # @return イベントリスト
  def fetch_event_list(calender_id)
    @calendar_service.list_events calender_id, single_events: true, order_by: 'startTime'
  end

  ##
  # カレンダーIDのリスト，検索日付から空き時間を取得します。
  # API reference : https://developers.google.com/calendar/v3/reference/freebusy/query
  #
  # @param calendar_id_list 対象のカレンダーIDのリスト Array<String>
  # @param time_min 検索日付(from) DateTime
  # @param time_max 検索日付(to) DateTime
  #
  # @return 空き時間オブジェクト(Google::Apis::CalendarV3::FreeBusyResponse)
  def fetch_free_busy(calendar_id_list, time_min, time_max)

    # calendar_idの配列をFreeBusyRequestItemに詰め替える
    request_items = []
    calendar_id_list.each do |calendar_id|
      request_items << Google::Apis::CalendarV3::FreeBusyRequestItem.new(id: calendar_id)
    end

    body = Google::Apis::CalendarV3::FreeBusyRequest.new
    body.items = request_items
    body.time_min = time_min
    body.time_max = time_max
    @calendar_service.query_freebusy body
  end
end

calender = Calender.new

calendar_id = 'ddvo53n31h5rpu1bq8j1g9lajjsdqqfo@import.calendar.google.com'
time_min = DateTime.parse('2018-12-03T00:00:00z')
time_max = DateTime.parse('2018-12-04T00:00:00z')
free_busy = calender.fetch_free_busy [calendar_id], time_min, time_max
puts free_busy.calendars