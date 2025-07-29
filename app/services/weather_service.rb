class WeatherService
  include HTTParty
  base_uri "api.openweathermap.org/data/2.5"

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def fetch
    # api call to get weather data
    response = self.class.get("/weather", query: {
      lat: @lat,
      lon: @lon,
      appid: Rails.application.credentials.dig(:weather_api),
      units: "metric"
    })

    data = response.parsed_response
    # return required api data
    {
      curr_temp: data["main"]["temp"],
      temp_min: data["main"]["temp_min"],
      temp_max: data["main"]["temp_max"],
      description: data["weather"].first["description"]
    }
  end
end