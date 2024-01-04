Rails.application.routes.draw do
  
  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :tags
    root 'articles#home'

  resources :articles do 
    resources :comments, only: [:create, :edit, :update, :destroy]
    resources :ratings, only: [:create]
  end
  
  # get 'export_ratings_to_csv', to: 'exports#export_ratings_to_csv'
  # get 'export_user_ratings', to: 'exports#export_user_ratings'

  # post 'users/:id/run_script', to: 'users#run_script', as: :run_script

  get "up" => "rails/health#show", as: :rails_health_check

  resources :likes, only: [:create, :destroy]

  resources :users, only: [:show]

  get 'users/:id/show_python_output', to: 'users#show_python_output', as: 'show_python_output'

end
