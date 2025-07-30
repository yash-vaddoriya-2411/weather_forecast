require 'rails_helper'

RSpec.describe "Forecasts", type: :request do
  let(:valid_address)   { "New York, NY" }
  let(:invalid_address) { "asldkfjalskdfj" }
  let(:special_address) { "Japan" }
  let(:geocoder_result) do
    double('result',
           address: "New York, NY, USA",
           coordinates: [ 40.7128, -74.0060 ],
           latitude: 40.7128,
           longitude: -74.0060,
           postal_code: "10001"
    )
  end
  let(:special_geocoder_result) do
    double('result',
           address: "Tokyo, Japan",
           coordinates: [ 35.6895, 139.6917 ],
           latitude: 35.6895,
           longitude: 139.6917,
           postal_code: "100-0001"
    )
  end
  let(:weather_data) do
    {
      curr_temp: 22.5,
      temp_min: 20.0,
      temp_max: 25.0,
      description: "clear sky"
    }
  end

  before { Rails.cache.clear }

  describe "GET /check_weather" do
    it "renders the check_weather template and form" do
      get check_weather_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Search by Location")
      expect(response.body).to include("Get Forecast")
    end
    it "does not show forecast results" do
      get check_weather_path
      expect(response.body).not_to include("Current Temperature")
    end
  end

  describe "POST /check_weather" do
    context "with a valid address" do
      before do
        allow(Geocoder).to receive(:search).and_return([ geocoder_result ])
        allow_any_instance_of(WeatherService).to receive(:fetch).and_return(weather_data)
      end

      it "renders the forecast results and shows fetched message" do
        post check_weather_path, params: { address: valid_address }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Current Temperature")
        expect(response.body).to include("clear sky".capitalize)
        expect(response.body).to include("Weather data fetched successfully for #{valid_address}.")
      end

      it "preserves the address in the form" do
        post check_weather_path, params: { address: valid_address }
        expect(response.body).to include("value=\"#{valid_address}\"")
      end

      it "caches the forecast and shows cached message on second request" do
        post check_weather_path, params: { address: valid_address }
        expect(response.body).to include("Weather data fetched successfully for #{valid_address}.")
        post check_weather_path, params: { address: valid_address }
        expect(response.body).to include("Weather data retrieved from cache for #{valid_address}.")
      end
    end

    context "with an invalid address" do
      before do
        allow(Geocoder).to receive(:search).and_return([])
      end

      it "redirects and shows invalid address message" do
        post check_weather_path, params: { address: invalid_address }
        expect(response).to have_http_status(:found)
        follow_redirect!
        expect(response.body).to include("Invalid address. Please enter a valid location.")
      end
    end

    context "with a blank address" do
      it "redirects and shows address not provided message" do
        post check_weather_path, params: { address: "" }
        expect(response).to have_http_status(:found)
        follow_redirect!
        expect(response.body).to include("Invalid address. Please enter a valid location.")
      end
    end

    context "when geocoder raises an error" do
      before do
        allow(Geocoder).to receive(:search).and_return(nil)
      end

      it "redirects and shows invalid address message" do
        post check_weather_path, params: { address: valid_address }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Failed to retrieve weather data. Please try again.")
      end
    end

    context "with special characters in address" do
      before do
        allow(Geocoder).to receive(:search).and_return([ special_geocoder_result ])
        allow_any_instance_of(WeatherService).to receive(:fetch).and_return(weather_data)
      end

      it "handles unicode and special characters" do
        post check_weather_path, params: { address: special_address }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Current Temperature")
        expect(response.body).to include("Weather data fetched successfully for #{special_address}.")
      end
    end

    context "when weather service returns nil" do
      before do
        allow(Geocoder).to receive(:search).and_return([ geocoder_result ])
        allow_any_instance_of(WeatherService).to receive(:fetch).and_return(nil)
      end

      it "renders the form with could not fetch weather data message" do
        post check_weather_path, params: { address: valid_address }
        expect(response.body).to include("Could not fetch weather data.")
      end
    end

    context "when weather service raises an error" do
      before do
        allow(Geocoder).to receive(:search).and_return([ geocoder_result ])
        allow_any_instance_of(WeatherService).to receive(:fetch).and_raise(StandardError, "API error")
      end

      it "renders the form with failed to retrieve weather data message" do
        post check_weather_path, params: { address: valid_address }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Failed to retrieve weather data. Please try again.")
      end
    end

    context "when geocoder returns coordinates without zip code" do
      let(:no_zip_geocoder_result) do
        double('result',
               address: "Mountain View, CA",
               coordinates: [ 37.3861, -122.0839 ],
               latitude: 37.3861,
               longitude: -122.0839,
               postal_code: nil
        )
      end

      before do
        allow(Geocoder).to receive(:search).and_return([ no_zip_geocoder_result ])
        allow_any_instance_of(WeatherService).to receive(:fetch).and_return(weather_data)
      end

      it "uses lat/lng for caching when zip code is not present" do
        post check_weather_path, params: { address: "Mountain View" }
        expect(response.body).to include("Weather data fetched successfully for Mountain View.")
        post check_weather_path, params: { address: "Mountain View" }
        expect(response.body).to include("Weather data retrieved from cache for Mountain View.")
      end
    end
  end
end
