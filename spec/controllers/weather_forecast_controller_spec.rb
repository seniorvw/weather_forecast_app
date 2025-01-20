require 'rails_helper'

RSpec.describe WeatherForecastController, type: :controller do
  let(:api_url) { 'https://api.weatherapi.com/v1/current.json?key=1786297403b24ebf80e71727251801&q=76011&aqi=no' }
  let(:weather_data) do
    {
      temperature: 20.5,
      high: 20.5,
      low: 68.9
    }
  end

  before do
    Rails.cache.clear
    # Stub the API request
    stub_request(:get, /api.weatherapi.com/).
      to_return(
        status: 200,
        body: {
          'current' => {
            'temp_c' => 20.5,
            'temp_f' => 68.9
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'sets default api_url' do
      get :index
      expect(assigns(:api_url)).to eq(api_url)
    end
  end

  describe 'GET #show' do
    context 'when data is not cached' do
      before do
        allow_any_instance_of(WeatherService).to receive(:extract_zip_code).and_return('76011')
      end

      it 'fetches and returns weather data' do
        get :show, params: { api_url: api_url }
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['weather_data']).to eq(weather_data.as_json)
        expect(json_response['from_cache']).to be false
      end

      it 'caches the weather data' do
        get :show, params: { api_url: api_url }
        expect(Rails.cache.exist?('76011')).to be true
        cached_data = Rails.cache.read('76011')
        expect(cached_data).to eq(weather_data)
      end
    end

    context 'when data is cached' do
      before do
        allow_any_instance_of(WeatherService).to receive(:extract_zip_code).and_return('76011')
        Rails.cache.write('76011', weather_data, expires_in: 30.minutes)
      end

      it 'returns cached weather data' do
        get :show, params: { api_url: api_url }
        
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['weather_data']).to eq(weather_data.as_json)
        expect(json_response['from_cache']).to be true
      end
    end

    context 'when zip code is not found' do
      before do
        allow_any_instance_of(WeatherService).to receive(:extract_zip_code).and_return(nil)
      end

      it 'returns bad request status with error message' do
        get :show, params: { api_url: 'invalid-url' }
        
        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error_message']).to eq('No ZIP code found in the API URL.')
      end
    end
  end
end 