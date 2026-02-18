Rails.application.routes.draw do
  devise_for :users
  resources :posts do
    collection do
      get 'fetch_discogs'
    end
  end

  root "posts#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
