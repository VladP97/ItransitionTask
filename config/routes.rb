Rails.application.routes.draw do
  resources :products do
    get "show_chart"
  end

  root :to => "products#index"
end
