Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  resources :products do
    get "show_chart"
  end

  root :to => "products#index"
end
