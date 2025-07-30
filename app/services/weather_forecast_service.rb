# frozen_string_literal: true

# This class has responsibility for calling both other services and fetch final result
class WeatherForecastService
  attr_reader :coordinates, :zip_code

  def initialize(address)
    @address = address
    # Calling service for coordinates like latitude, longitude, zip_code
    @coordinates = GeocodingService.new(@address).coordinates
    @zip_code = @coordinates[:zip_code] if @coordinates.present?
  end

  def fetch_forecast
    # Extract zip code from coordinates
    return nil if coordinates.blank?

    # Generate cache key using zip code but if it is not available then using latitude and longitude
    cache_key = if zip_code.present?
                  "forecast_#{zip_code}"
    else
                  "forecast_#{coordinates[:lat]}_#{coordinates[:lng]}"
    end
    # Read from cache if above key already present
    @forecast = Rails.cache.read(cache_key)

    if @forecast.present?
      @from_cache = true
    else
        @forecast = WeatherService.new(coordinates[:lat], coordinates[:lng]).fetch

        if @forecast.present?
          # Store data in cache for future usage
          Rails.cache.write(cache_key, @forecast, expires_in: 30.minutes)
        end
        @from_cache = false
    end
    @forecast
  end

  def from_cache?
    @from_cache
  end
end
