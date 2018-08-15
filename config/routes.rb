Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :transactions
  post '/monzo_webhook_add', to: 'transactions#monzo_webhook_add'
  get '/summary', to: 'transactions#summary'
end
