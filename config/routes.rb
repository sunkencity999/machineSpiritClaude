Rails.application.routes.draw do

  root 'chat#index'
  post 'chat/ask', to: 'chat#ask', as: 'ask_claude'
  post 'delete_thread', to: 'chat#delete_thread'
  
  resources :chat, only: [:index, :ask] do
    collection do
      get :download_latest_response, defaults: { format: 'pdf' }
    end
  end

end

