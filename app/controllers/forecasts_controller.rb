class ForecastsController < ApplicationController
  def check_weather
    @address = params[:address] || ""

    # If request post then only get coordinates
    if request.post?
      # Check for if address not blank
      if @address.blank?
        flash[:alert] = "Address not provided or can't be blank"
        redirect_to root_path and return
      end

      # Calling service for coordinates like latitude, longitude, zip_code
      coordinates = GeocodingService.new(@address).coordinates

      if coordinates.blank?
        flash[:alert] = "Invalid address. Please enter a valid location."
        redirect_to root_path and return
      end

      # Extract zip code from coordinates
      @zip_code = coordinates[:zip_code] if coordinates[:zip_code].present?

      # Generate cache key using zip code but if it is not available then using latitude and longitude
      cache_key = if @zip_code.present?
                    "forecast_#{@zip_code}"
      else
                    "forecast_#{coordinates[:lat]}_#{coordinates[:lng]}"
      end

      # Read from cache if above key already present
      @forecast = Rails.cache.read(cache_key)

      if @forecast.present?
        @from_cache = true
        flash.now[:notice] = "Weather data retrieved from cache for #{@address}."
      else
        begin
          @forecast = WeatherService.new(coordinates[:lat], coordinates[:lng]).fetch

          if @forecast.present?
            # Store data in cache for future usage
            Rails.cache.write(cache_key, @forecast, expires_in: 30.minutes)
            flash.now[:notice] = "Weather data fetched successfully for #{@address}."
          else
            flash.now[:alert] = "Could not fetch weather data."
          end
          @from_cache = false
          # Rescue error
        rescue => e
          Rails.logger.error("WeatherService Error: #{e.message}")
          flash.now[:alert] = "Failed to retrieve weather data. Please try again."
          @forecast = nil
        end
      end
    end
  end
end
