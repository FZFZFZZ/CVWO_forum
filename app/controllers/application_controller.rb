class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?
	helper_method :admin_user?

	protected

	def after_sign_in_path_for(resource)
    	articles_path
  	end

  	def after_sign_out_path_for(resource_or_scope)
    	root_path
  	end

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_in, keys: [:login])
  		devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation, :favshare, :contactshare, :historyshare])
    	devise_parameter_sanitizer.permit(:account_update, keys: [:favshare, :contactshare, :historyshare, :instagram, :phone, :username, :email, :password, :password_confirmation])
	end


	private

	def admin_user?
		current_user && current_user.username == 'admin_dTkQDvAZf'
	end
end
