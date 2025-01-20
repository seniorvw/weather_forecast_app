require "test_helper"

class WeatherForecastControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get weather_forecast_show_url
    assert_response :success
  end
end
