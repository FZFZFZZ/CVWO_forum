Rails.application.routes.draw do
  
  get '/stats/chart_data', to: 'stats#chart_data'

  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :tags
    root 'articles#home'

  resources :articles do 
    resources :comments, only: [:create, :edit, :update, :destroy, :new]
    resources :ratings, only: [:create, :edit, :update]
  end

  resources :comments do
    resources :like_comments, only: [:create, :destroy]
  end
  
  # get 'export_ratings_to_csv', to: 'exports#export_ratings_to_csv'
  # get 'export_user_ratings', to: 'exports#export_user_ratings'

  get "up" => "rails/health#show", as: :rails_health_check

  resources :likes, only: [:create, :destroy]

  resources :users, only: [:show]

  get 'users/:id/show_python_output', to: 'users#show_python_output', as: 'show_python_output'

end
