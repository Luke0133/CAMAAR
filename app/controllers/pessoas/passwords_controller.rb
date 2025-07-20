class Pessoas::PasswordsController < Devise::PasswordsController

  # Metodo chamado quando o token é inválido
  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      flash[:alert] = "Token de redefinição de senha é inválido" if is_navigational_format?
      redirect_to new_pessoa_session_path
      return true
    end
  end

  # Também pode sobrescrever o metodo responsável pelo update para capturar token inválido
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      successful_password_update
    else
      failed_password_update
    end
  end

  def successful_password_update
    resource.unlock_access! if unlockable?(resource)
    flash[:notice] = "Senha redefinida com sucesso!"
    sign_in(resource_name, resource)
    session[:email] = resource.email
    respond_with resource, location: after_resetting_password_path_for(resource)
  end

  def failed_password_update
    session[:email] = nil
    if resource.errors.details[:reset_password_token].present?
      flash[:alert] = "Token de redefinição de senha é inválido"
    end
    respond_with resource
  end

  protected

  def after_resetting_password_path_for(resource)
    user_avaliacoes_path
  end
end
