class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?

	protected

	def after_sign_in_path_for(resource)
    	articles_path
  	end

  	def after_sign_out_path_for(resource_or_scope)
    	root_path
  	end

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_in, keys: [:login])
  		devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation])
    	devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :password, :password_confirmation])
	end
end