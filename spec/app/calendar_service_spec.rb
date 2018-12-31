require_relative '../../app/calendar_service'

RSpec.describe CalendarService do
  before do
    settings = { 'start_time' => '9:00',
                 'end_time' => '19:00',
                 'interval_time' => '00:30',
                 'start_date' => '2018/12/01',
                 'end_date' => '2018/12/08' }
    allow(YAML).to(receive(:load_file)
                       .with('../setting.yaml')
                       .and_return(settings))
    @service = CalendarService.new
  end

  describe '#calc_interval' do
    it '正常に時間差が計算できること' do
      from = DateTime.new 2018, 1, 1
      to = DateTime.new 2018, 1, 1, 12

      expect(@service.calc_interval(from, to)).to eq 12 * 60
    end
  end

  describe '#complete_free_days' do
    it '不足している日付のHashがArrayに追加されていること(数の検証)' do
      free_time = [{ start_time: DateTime.new(2018, 12, 2) }]
      expect(@service.complete_free_days(free_time).length).to eq 8
    end

    it '追加された日付のHashの情報がstart_time, end_timeになっていること' do
      result = @service.complete_free_days([])[0]
      expect(result[:start_time].hour).to eq 9
      expect(result[:start_time].min).to eq 0
      expect(result[:end_time].hour).to eq 19
      expect(result[:end_time].min).to eq 0
    end

    it '追加されたものも含め，start_timeでソートされていること' do
      free_time = [{ start_time: DateTime.new(2018, 12, 5) },
                   { start_time: DateTime.new(2018, 12, 2) }]

      result = @service.complete_free_days free_time

      1.upto 7 do |i|
        expect(result[i - 1][:start_time].day).to be <= result[i][:start_time].day
      end
    end
  end
end
