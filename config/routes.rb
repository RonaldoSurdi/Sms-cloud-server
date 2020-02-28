Rails.application.routes.draw do

  scope :admin, module: "admin" do
    devise_for :administrators
    resources :administrators
    resources :profile, only: [:edit, :update], as: :profile_administrator
    resources :roles
    resources :representatives, only: [:index, :show, :update, :edit]
    resources :customers, only: [:index, :show, :update]
    resources :plans
    resources :licenses
    resources :our_customers

    resources :license_movements, only: [:index, :show, :update, :destroy] do
      patch :multiple_confirm, on: :collection
      delete :multiple_destroy, on: :collection
    end
    resources :plan_movements, only: [:index, :show, :update, :destroy] do
      patch :multiple_confirm, on: :collection
      delete :multiple_destroy, on: :collection
    end

    resources :home, only: [:index]

    root "home#index", as: :administrator_root
  end

  scope :representante, module: "representante" do
    devise_for :representatives, controllers: { confirmations: "confirmations" }
    resources :profile, only: [:edit, :update], as: :profile_representative
    resources :customers, only: [:index, :show], as: :representative_customers do
      get :verify_customer, on: :member
      collection do
        get :sale
        post :sell
      end
    end
    resources :license_movements, only: [:index, :show, :new, :create, :destroy], as: :representative_license_movements

    root "home#index", as: :representative_root
  end

  scope :clientes, module: "clientes" do
    devise_for :customers, controllers: { confirmations: "confirmations" }
    resources :profile, only: [:edit, :update], as: :profile_customer
    resources :envios, only: [:new, :create]
    resources :relatorios, only: [:index, :show]
    resources :painel, only: [:index]
    resources :importacao, only: [:new, :create]
    resources :configuracoes, only: [:index, :update]
    resources :contacts do
      get 'all', on: :collection
    end
    resources :contact_groups do
      get 'get_contacts', on: :collection
    end

    resources :painel, only: [:index]
    resources :compra_licencas, only: [:index]

    resources :compra_pacotes, only: [:index, :show, :create] do
      get "aguarde", on: :collection
    end

    get 'painel_opcoes/index'
    root "painel_opcoes#index", as: :customer_root
  end

  scope :publico, module: "publico" do
    resources :solucoes, only: [:index]
    resources :quem_somos, only: [:index]
    resources :fale_conosco, only: [:index, :create]
    resources :nossos_clientes, only: [:index]
  end

  scope :api, module: "api" do
    resources :cep, only: [:show]
    resources :messages, only: [:create, :update, :index, :show] do
      post :status, on: :collection
    end
  end

  resources :representatives, only: [:new, :create], as: :public_representatives do
    get 'por_estado', on: :collection
  end

  resources :customers, only: [:new, :create], as: :public_customers

  resources :cep, only: [:show], as: :public_cep

  resources :representantes, only: [:index]

  resources :politica_privacidade, only: [:index]

  root "home#index"
end
