class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(resource)
    articles_path
  end
  
end