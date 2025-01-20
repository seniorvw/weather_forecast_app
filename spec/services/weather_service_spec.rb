require 'rails_helper'

RSpec.describe WeatherService do
  let(:api_url) { 'https://api.weatherapi.com/v1/current.json?key=1786297403b24ebf80e71727251801&q=76011&aqi=no' }
  let(:service) { described_class.new(api_url) }

  describe '#extract_zip_code' do
    it 'extracts zip code from valid URL' do
      expect(service.extract_zip_code(api_url)).to eq('76011')
    end

    it 'returns nil for invalid URL' do
      expect(service.extract_zip_code('invalid-url')).to be_nil
    end

    it 'returns nil for blank URL' do
      expect(service.extract_zip_code('')).to be_nil
    end
  end

  describe '#fetch_weather' do
    let(:success_response) do
      {
        'current' => {
          'temp_c' => 20.5,
          'temp_f' => 68.9,
          'feelslike_c' => 19.5,
          'feelslike_f' => 67.1
        }
      }
    end

    before do
      stub_request(:get, api_url)
        .to_return(
          status: 200,
          body: success_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'returns formatted weather data on successful API call' do
      result = service.fetch_weather
      expect(result).to eq({
        temperature: 20.5,
        high: 20.5,
        low: 68.9
      })
    end

    context 'when API call fails' do
      before do
        stub_request(:get, api_url).to_return(status: 404)
      end

      it 'returns nil on failed API call' do
        expect(service.fetch_weather).to be_nil
      end
    end

    context 'when JSON parsing fails' do
      before do
        stub_request(:get, api_url).to_return(
          status: 200,
          body: 'invalid json'
        )
      end

      it 'returns nil on JSON parse error' do
        expect(service.fetch_weather).to be_nil
      end
    end
  end
end 