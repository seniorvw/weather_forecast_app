require 'test_helper'

class WeatherServiceTest < ActiveSupport::TestCase
  def setup
    @valid_url = "https://api.weatherapi.com/v1/current.json?key=1786297403b24ebf80e71727251801&q=77505&aqi=no"
    @invalid_url = "invalid-url"
    @weather_service = WeatherService.new(@valid_url)
  end

  test "should extract zip code from valid API URL" do
    assert_equal '77505', @weather_service.zip_code
  end

  test "should return nil for invalid API URL" do
    invalid_service = WeatherService.new(@invalid_url)
    assert_nil invalid_service.zip_code
  end

  test "should fetch weather data" do
    weather_data = @weather_service.fetch_weather
    assert_not_nil weather_data
    assert weather_data[:temperature]
  end

  test "should return nil when API response is not successful" do
    stub_request(:get, @valid_url).to_return(status: 404)
    weather_data = @weather_service.fetch_weather
    assert_nil weather_data
  end
end
