Rails.application.routes.draw do
  devise_for :users

  resources :users do
  post :send_prompt_response, on: :member
  end

  resources :emails, only: [] do
  post :send_prompt_response, on: :collection
  end


  root 'chat#index'
  post 'chat/ask', to: 'chat#ask', as: 'ask_claude'
  post 'delete_thread', to: 'chat#delete_thread'
  post 'chat/create', to: 'chat#create', as: 'chat_create'
  post 'chat/save', to: 'chat#create', as: 'chat_save'
  
  
  resources :conversations, only: [:destroy]


  resources :chat, only: [:index, :create]

  resources :chat, only: [:index, :ask] do
    collection do
      get :download_latest_response, defaults: { format: 'pdf' }
    end
  end

end

