Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :transactions
  get 'transactions/summary'
  get '/summary', to: 'transactions#summary'
end
