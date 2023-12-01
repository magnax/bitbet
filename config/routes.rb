BitbetTk::Application.routes.draw do
  get 'operations/withdraw'
  get 'accounts/create'

  # root path
  root to: 'static_pages#index'

  # admin routes
  get 'admin/menu', via: 'get', as: 'admin'
  match '/admin/:action', to: 'admin#action', via: 'get'
  match '/admin/account_fix/:id', to: 'admin#account_fix', via: 'get', as: 'admin_account_fix'

  get 'bids/new'
  get 'bids/create'
  get 'bids_controller/new'
  get 'bids_controller/create'

  # static pages paths
  match '/login',  to: 'sessions#new',         via: 'get'
  match '/logout', to: 'sessions#destroy',     via: 'delete'
  match '/password_reset', to: 'users#password_reset', via: 'get'
  match '/faq', to: 'static_pages#faq', via: 'get'
  match '/terms', to: 'static_pages#terms', via: 'get', as: 'terms'
  match '/contact', to: 'static_pages#contact', via: 'get'
  match '/deposit_address', to: 'accounts#create_deposit_address', via: 'get', as: 'deposit_address'
  match '/withdraw', to: 'operations#withdraw', via: 'get', as: 'withdraw'

  match '/bets/:id/publish', to: 'bets#publish', via: 'get', as: 'publish'
  match '/bets/:id/reject', to: 'bets#reject', via: 'get', as: 'reject'
  match '/bets/:id/ban', to: 'bets#ban', via: 'get', as: 'ban'
  match '/bets/:id/end', to: 'bets#end_bet', via: 'get', as: 'end'
  match '/bets/:id/settle', to: 'bets#settle', via: 'patch', as: 'settle'
  match '/bets_404', to: 'bets#bet404', via: 'get', as: 'bet404'

  resources :bets do
    resources :bids
  end
  resources :users, only: %i[create new show] do
    get :name_availability, on: :collection
  end
  resources :sessions, only: %i[new create destroy]
  resources :accounts, only: %i[new create]
  resources :operations, only: [:create]
end
