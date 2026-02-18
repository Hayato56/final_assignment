Rails.application.routes.draw do
  get 'static_pages/terms'
  get 'static_pages/privacy'
  devise_for :users
  resources :posts do
    collection do
      get 'fetch_discogs'
    end
  end

  root "posts#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
