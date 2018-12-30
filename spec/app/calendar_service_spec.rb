require_relative '../../app/calendar_service'

RSpec.describe CalendarService do
  describe '#calc_interval' do
    before do
      @settings = { 'start_time' => '9:00',
                    'end_time' => '19:00',
                    'interval_time' => '00:30',
                    'start_date' => '2018/12/01',
                    'end_date' => '2018/12/02' }
    end
    it '正常に時間差が計算できること' do
      from = DateTime.new 2018, 1, 1
      to = DateTime.new 2018, 1, 1, 12

      allow(YAML).to receive(:load_file)
                         .with('../setting.yaml')
                         .and_return(@settings)

      service = CalendarService.new
      expect(service.calc_interval(from, to)).to eq 12 * 60
    end
  end
end
