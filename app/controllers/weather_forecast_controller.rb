class WeatherForecastController < ApplicationController
  before_action :set_api_url, only: [:show]

  # Action to render the input form (root URL)
  def index
    @api_url = 'https://api.weatherapi.com/v1/current.json?key=1786297403b24ebf80e71727251801&q=76011&aqi=no'
  end

  # Action to fetch and display weather forecast data
  def show
    # If no ZIP code is found, return the error message
    if @zip_code.nil?
      render json: { error_message: "No ZIP code found in the API URL." }, status: :bad_request and return
    end

    # Check if forecast data is cached for the given ZIP code
    if Rails.cache.exist?(@zip_code)
      @weather_data = Rails.cache.read(@zip_code)
      @from_cache = true
    else
      # Fetch weather data using WeatherService
      @weather_data = WeatherService.new(@api_url).fetch_weather
      if @weather_data
        # Cache the forecast data for 30 minutes by ZIP code
        Rails.cache.write(@zip_code, @weather_data, expires_in: 30.minutes)
      end
      @from_cache = false
    end

    render json: { weather_data: @weather_data, from_cache: @from_cache }
  end

  private

  # Set the API URL based on user input or default value
  def set_api_url
    @api_url = params[:api_url] || 'https://api.weatherapi.com/v1/current.json?key=1786297403b24ebf80e71727251801&q=76011&aqi=no'
    weather_service = WeatherService.new(@api_url)
    @zip_code = weather_service.extract_zip_code(@api_url)
  end
end
