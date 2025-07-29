class ForecastsController < ApplicationController
  def check_weather
    @address = params[:address] || ""
    # if request post then only get coordinates
    if request.post? && !@address.blank?
      # calling service for coordinates like latitude, longitude, zip_code
      coordinates = GeocodingService.new(@address).coordinates

      # call open weather api using service
      @forecast = WeatherService.new(coordinates[:lat], coordinates[:lng]).fetch
    end
  end
end
