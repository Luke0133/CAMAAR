Rails.logger.info "ABACAXI DE NOVO"
Rails.application.routes.draw do
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

 # devise_for :pessoas

 
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")

  #root "templates#index"

  # root "posts#index"

  get "/dashboard", to: "home#index", as: :dashboard

  resources :templates, only: [:index, :show, :edit, :update]
  resources :formularios, only: [:new, :create, :index]

  # remove sign up
  devise_for :pessoas, controllers: {
    sessions: 'pessoas/sessions',
    passwords: 'pessoas/passwords'
  }#, as: :pessoa

  devise_scope :pessoa do
    get '/login', to: 'pessoas/sessions#new', as: :login
  end
  root to: redirect('/login')
  
  namespace :admin do
    get "resultados", to: "resultados#index", as: :resultados
    get "resultados/:id/preparar_download", to: "resultados#preparar_download", as: :preparar_download
    get "resultados/:id/download", to: "resultados#download", as: :download_resultado
    get "/gerenciamento" => "gerenciamento#index"
    post '/gerenciamento/importar', to: 'gerenciamento#importar', as: 'importar_dados'
  end
 
  
  namespace :user do
    get 'avaliacoes', to: 'avaliacoes#index'
    resources :formularios, only: [:show]
    resources :avaliacoes, only: [:index] do
      member do
        get :responder
        post :enviar_respostas
      end
    end
  end
end
