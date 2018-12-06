require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

class Calender
  APPLICATION_NAME = '空き時間出力'.freeze
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  CREDENTIALS_PATH = '../credentials.json'.freeze
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

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
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    service.list_calendar_lists
  end
end

calender = Calender.new

calender.fetch_calender_list.items.each do |item|
  puts "Calender ID : #{item.id}, Summary : #{item.summary}"
end