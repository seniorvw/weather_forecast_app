require 'faraday'
require 'json'
require 'uri'

class WeatherService
  def initialize(api_url)
    @api_url = api_url
    @zip_code = extract_zip_code(@api_url)
  end

  # Fetch weather data from the API
  def fetch_weather
    return nil unless @zip_code

    # Fetch weather data using the provided API URL
    response = Faraday.get(@api_url)
    return nil if response.status != 200

    data = JSON.parse(response.body)
    {
      temperature: data['current']['temp_c'],
      high: data['current']['temp_c'],
      low: data['current']['temp_f'],
    }
  rescue JSON::ParserError
    nil # Handle JSON parsing errors gracefully
  end

  def zip_code
    @zip_code
  end

  # Extract ZIP code (or city name) from the URL
  def extract_zip_code(url)
    return nil if url.blank?
  
    begin
      uri = URI.parse(url)
      return nil unless uri.query
  
      params = URI.decode_www_form(uri.query).to_h
      zip_code = params['q'] || params['zipcode']  # Check for either 'q' or 'zipcode'
      
      return zip_code if zip_code.present?
  
    rescue URI::InvalidURIError => e
      Rails.logger.error "Invalid URL provided: #{url}"
      return nil
    end
  end
  
end
