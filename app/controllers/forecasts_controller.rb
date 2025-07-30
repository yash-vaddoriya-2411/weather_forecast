class ForecastsController < ApplicationController
  before_action :get_address, only: [ :check_weather ]
  def index
    initialize_weather_data
    render :check_weather
  end

  def check_weather
    service = WeatherForecastService.new(@address)

    handle_invalid_address and return if service.coordinates.blank?
    # Get required data from service
    assign_weather_data(service)

    flash.now[:notice] = @from_cache ? "Weather data retrieved from cache for #{@address}." : "Weather data fetched successfully for #{@address}."

    rescue => e
      handle_service_error(e)
  end

  private

  def initialize_weather_data
    @address = ""
    @forecast = nil
    @zip_code = nil
    @from_cache = false
  end

  def handle_invalid_address
    flash[:alert] = "Invalid address. Please enter a valid location."
    redirect_to check_weather_path
  end

  def assign_weather_data(service)
    @forecast = service.fetch_forecast
    @zip_code = service.zip_code
    @from_cache = service.from_cache?

    unless @forecast.present?
      flash.now[:alert] = "Could not fetch weather data."
    end
  end

  def handle_service_error(error)
    Rails.logger.error("WeatherService Error: #{error.message}")
    flash.now[:alert] = "Failed to retrieve weather data. Please try again."
    @forecast = nil
    render :check_weather
  end

  def get_address
    @address = params[:address].strip
  end
end
