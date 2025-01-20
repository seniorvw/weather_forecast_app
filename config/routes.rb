Rails.application.routes.draw do
  # Route for root path (input form)
  root to: 'weather_forecast#index'

  # Route to process the forecast request and display the result
  get 'weather_forecast/show', to: 'weather_forecast#show'
end
