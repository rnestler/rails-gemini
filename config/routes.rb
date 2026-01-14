Rails.application.routes.draw do
  root "gemini#index"
  get "about", to: "gemini#about"

  get "up" => "rails/health#show", as: :rails_health_check
end
