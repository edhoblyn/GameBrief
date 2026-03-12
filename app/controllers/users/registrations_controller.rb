class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: [:update]

  protected

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username avatar_url avatar_image cover_image])
  end

  def update_resource(resource, params)
    if credentials_change_requested?(resource, params)
      super
    else
      params.delete(:current_password)
      params.delete(:password)
      params.delete(:password_confirmation)
      resource.update_without_password(params)
    end
  end

  private

  def credentials_change_requested?(resource, params)
    params[:email] != resource.email ||
      params[:password].present? ||
      params[:password_confirmation].present? ||
      params[:current_password].present?
  end
end
