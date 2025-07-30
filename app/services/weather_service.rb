# This class has responsibility to weather data from external api calls
class WeatherService
  include HTTParty
  base_uri "api.openweathermap.org/data/2.5"

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def fetch
    # api call to get weather data
    response = self.class.get("/forecast", query: {
      lat: @lat,
      lon: @lon,
      units: "metric",
      appid: Rails.application.credentials.dig(:weather_api)
    })

    data = response.parsed_response

    # Pick the first forecast (next 3-hour block)
    first_entry = data["list"]&.first

    return nil unless first_entry
    # return required api data
    {
      curr_temp: first_entry["main"]["temp"],
      temp_min: first_entry["main"]["temp_min"],
      temp_max: first_entry["main"]["temp_max"],
      description: first_entry["weather"].first["description"]
    }
  end
end
