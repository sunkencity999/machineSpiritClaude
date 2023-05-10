Rails.application.routes.draw do
  get 'contact/index', as: 'contact'
  get 'user_guide/index', as: 'user_guide'
  get 'premium_features/index', as: 'premium_features'
  get 'home/index', as: 'home'

  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'devise/sessions',
    passwords: 'devise/passwords',
    confirmations: 'devise/confirmations',
    unlocks: 'devise/unlocks'
  }
  
  devise_scope :user do
  post '/subscriptions/cancel', to: 'subscriptions#cancel', as: 'cancel_subscriptions'
  end
  resources :users do
    post :send_prompt_response, on: :member
  end

  resources :emails, only: [] do
    post :send_prompt_response, on: :collection
  end

  root 'chat#index'
  post 'text-to-speech', to: 'text_to_speech#create'
  post 'chat/ask', to: 'chat#ask', as: 'ask_claude'
  post 'delete_thread', to: 'chat#delete_thread'
  post 'chat/create', to: 'chat#create', as: 'chat_create'
  post 'chat/save', to: 'chat#create', as: 'chat_save'
  post 'contact', to: 'contact#create'
  get 'api_key', to: 'text_to_speech#api_key'

  resources :conversations, only: [:destroy]
  resources :chat, only: [:index, :create]

  resources :chat, only: [:index, :ask] do
    collection do
      get :download_latest_response, defaults: { format: 'pdf' }
    end
  end
end

