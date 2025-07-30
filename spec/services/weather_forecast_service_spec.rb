RSpec.describe WeatherForecastService do
  let(:address) { "New York" }
  let(:coordinates) { { lat: 40.7128, lng: -74.0060, zip_code: "10001" } }
  let(:forecast) { { curr_temp: 22.5, temp_min: 20.0, temp_max: 25.0, description: "clear sky" } }

  before do
    allow_any_instance_of(GeocodingService).to receive(:coordinates).and_return(coordinates)
    allow_any_instance_of(WeatherService).to receive(:fetch).and_return(forecast)
    Rails.cache.clear
  end

  it "fetches forecast and stores it in cache" do
    service = described_class.new(address)
    expect(service.fetch_forecast).to eq(forecast)
    expect(service.from_cache?).to be false

    service2 = described_class.new(address)
    expect(service2.fetch_forecast).to eq(forecast)
    expect(service2.from_cache?).to be true
  end
end
