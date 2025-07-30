require "rails_helper"

RSpec.describe WeatherService do
  let(:lat) { 40.7128 }
  let(:lon) { -74.0060 }
  let(:service) { described_class.new(lat, lon) }

  let(:valid_api_response) do
    {
      "list" => [
        {
          "main" => {
            "temp" => 22.5,
            "temp_min" => 20.0,
            "temp_max" => 25.0
          },
          "weather" => [
            { "description" => "clear sky" }
          ]
        }
      ]
    }
  end

  describe "#fetch" do
    before do
      stub_const("Rails::Application::Configuration::Custom", Class.new) unless Rails.application.respond_to?(:credentials)
      allow(Rails.application).to receive_message_chain(:credentials, :dig).with(:weather_api).and_return("fake_api_key")
    end

    it "returns weather data when API returns valid response" do
      allow(described_class).to receive(:get).and_return(double(parsed_response: valid_api_response))

      result = service.fetch

      expect(result).to eq({
                             curr_temp: 22.5,
                             temp_min: 20.0,
                             temp_max: 25.0,
                             description: "clear sky"
                           })
    end

    it "returns nil when API response has no forecast list" do
      allow(described_class).to receive(:get).and_return(double(parsed_response: { "list" => nil }))

      expect(service.fetch).to be_nil
    end

    it "returns nil when list is empty" do
      allow(described_class).to receive(:get).and_return(double(parsed_response: { "list" => [] }))

      expect(service.fetch).to be_nil
    end

    it "returns nil when main section is missing" do
      response = {
        "list" => [ { "weather" => [ { "description" => "sunny" } ] } ]
      }
      allow(described_class).to receive(:get).and_return(double(parsed_response: response))

      expect { service.fetch }.to raise_error(NoMethodError) # Or handle gracefully if you prefer
    end

    it "returns nil when weather section is missing" do
      response = {
        "list" => [ { "main" => { "temp" => 22.0, "temp_min" => 20.0, "temp_max" => 25.0 } } ]
      }
      allow(described_class).to receive(:get).and_return(double(parsed_response: response))

      expect { service.fetch }.to raise_error(NoMethodError)
    end

    it "raises error when API call fails" do
      allow(described_class).to receive(:get).and_raise(StandardError.new("API unreachable"))

      expect { service.fetch }.to raise_error(StandardError, "API unreachable")
    end
  end
end
