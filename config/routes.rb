BitbetTk::Application.routes.draw do

  get "accounts/create"
  get "admin/menu"
  get "admin/info"
  #root path
  root "static_pages#index"

  get "bids/new"
  get "bids/create"
  get "bids_controller/new"
  get "bids_controller/create"
  get "bets/index"
  get "bets/create"


  #static pages paths
  match '/register',  to: 'users#new',            via: 'get'
  match '/login',  to: 'sessions#new',         via: 'get'
  match '/logout', to: 'sessions#destroy',     via: 'delete'
  match '/password_reset', to: 'users#password_reset',     via: 'get'
  match '/profile',  to: 'users#show',         via: 'get'
  match "/faq", to: "static_pages#faq", via: "get"
  match "/terms", to: "static_pages#terms", via: "get"
  match "/contact", to: "static_pages#contact", via: "get"
  match "/address", to: "users#withdrawal_address", via: "get", as: 'withdrawal_address'
  match "/deposit_address", to: "users#deposit_address", via: "get", as: 'deposit_address'

  match "/bets/:id/publish", to: "bets#publish", via: "get", as: 'publish'
  match "/bets/:id/reject", to: "bets#reject", via: "get", as: 'reject'
  match "/bets/:id/ban", to: "bets#ban", via: "get", as: 'ban'
  match "/bets/:id/end", to: "bets#end", via: "get", as: 'end'
  match "/bets/404", to: "bets#bet404", via: "get", as: "bet404"

  resources :bets do
    resources :bids
  end
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :accounts, only: [:new, :create]

end
