require_relative '../../../../app/services/google_calendar/calendar_service'

class Api::V1::FreetimeController < ApplicationController

  def initialize
    @calendar_ids = YAML.load_file 'config/settings/calendar_ids.yaml'
  end

  def get

    start_date = params[:start_date]
    end_date = params[:end_date]
    start_time = params[:start_time]
    end_time = params[:end_time]
    interval_time = params[:interval_time]

    unless start_date && end_date && start_time && end_time && interval_time
      render status: 400, json: { message: 'パラメータが不正です。' }
      return
    end

    service = CalendarService.new(start_date, end_date, start_time, end_time, interval_time)
    result = service.calc_free_time

    render status: 200, json: result.to_json
  end

  def test
    render json: { status: 200, message: 'test' }
  end
end
