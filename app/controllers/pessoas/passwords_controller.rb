##
# Controladora responsável pela gestão de senhas de usuários (redefinição de senha).
# Herda de Devise::PasswordsController (gem utilizada para autenticação).
#
# Usa o layout personalizado "login".
#
# Funcionalidades principais:
# - Permitir redefinição de senha
# - Gerenciar solicitações de redefinição de senha
# - Validar tokens de redefinição de senha
class Pessoas::PasswordsController < Devise::PasswordsController

##
# Verifica se o token de redefinição de senha foi passado.
#
# Se o token não estiver presente, exibe uma mensagem de erro e redireciona para a página de login.
#
# Não recebe argumentos diretos.
# 
# Retorno:
# - Retorna true se o token estiver ausente (usado nos testes).
#
# Efeitos colaterais:
# - Define uma mensagem flash de alerta se o token estiver ausente
# - Redireciona para a página de login
  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      flash[:alert] = "Token de redefinição de senha é inválido" if is_navigational_format?
      redirect_to new_pessoa_session_path
      return true
    end
  end

##
# Redefine a senha do usuário (sobrescreve método do Devise).
#
# Recebe o token de redefinição de senha via \params[:reset_password_token].
# Verifica se o token é válido.
#
# Não recebe argumentos diretos.
# Não há retorno explícito, mas renderiza a view de redefinição de senha.
#
# Exemplo de uso:
#   PATCH /pessoa/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      successful_password_update
    else
      failed_password_update
    end
  end

##
# Redefine a senha do usuário (método auxiliar).
#
# Recebe os parâmetros de redefinição de senha via \params[:pessoa].
# Inicia a sessão do usuário e redireciona para o caminho após a redefinição de senha bem-sucedida.
#
# Não recebe argumentos diretos.
# Não há retorno.
#
# Efeitos colaterais:
# - Define uma mensagem flash de sucesso
# - Autentica o usuário na sessão
# - Define o email do usuário na sessão
# - Redireciona para o caminho após a redefinição de senha bem-sucedida
  def successful_password_update
    resource.unlock_access! if unlockable?(resource)
    flash[:notice] = "Senha redefinida com sucesso!"
    sign_in(resource_name, resource)
    session[:email] = resource.email
    respond_with resource, location: after_resetting_password_path_for(resource)
  end

##
# Redireciona o usuário com uma mensagem de erro (método auxiliar).
#
# Recebe os parâmetros de redefinição de senha via \params[:pessoa].
# Exibe uma mensagem de erro caso a redefinição de senha falhe.
#
# Não recebe argumentos diretos.
# Não há retorno.
#
# Efeitos colaterais:
# - Define uma mensagem flash de erro
# - Limpa as senhas do recurso
# - Renderiza a view de redefinição de senha com status 422 (entidade não processável)
  def failed_password_update
    session[:email] = nil
    if resource.errors.details[:reset_password_token].present?
      flash[:alert] = "Token de redefinição de senha é inválido"
    end
    respond_with resource
  end

  protected
##
# Define o caminho para redirecionamento após redefinição de senha (método auxiliar).
#
# Retorna o caminho para a página de dashboard.
#
# Argumento:
# - resource: o recurso (usuário) que teve a senha redefinida
# Retorno:
# - Caminho para a página de avaliações do usuário
  def after_resetting_password_path_for(resource)
    dashboard_path
  end
end
