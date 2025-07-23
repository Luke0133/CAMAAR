##
# Controladora responsável pela gestão de sessões de usuários (login/logout).
# Herda de Devise::SessionsController (gem utilizada para autenticação).
#
# Usa o layout personalizado "login".
#
# Funcionalidades principais:
# - Permitir login e logout de usuários
# - Gerenciar sessões de usuários
#
class Pessoas::SessionsController < Devise::SessionsController
  layout 'login'

  before_action :configure_sign_in_params, only: [:create]
  before_action :set_devise_vars, only: [:new, :create]

  ##
  # Cria uma nova sessão para o usuário autenticado (sobrescreve método do Devise).
  #
  # Recebe os parâmetros de autenticação via \params[:pessoa].
  # Identifica se a autenticação foi bem-sucedida ou não.
  #
  # Não recebe argumentos diretos.
  # Não há retorno explícito, mas redireciona ou renderiza a view conforme o resultado da autenticação.
  #
  # Exemplo de uso:
  #   POST /pessoa/sign_in
  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource
      successful_login
    else
      failed_login
    end
  end

##
# Cria uma nova sessão para o usuário autenticado (método auxiliar).
#
# Recebe os parâmetros de autenticação via \params[:pessoa].
# Inicia a sessão do usuário e redireciona para o caminho após o login bem-sucedido.
#
# Não recebe argumentos diretos.
# Não há retorno.
#
# Efeitos colaterais:
# - Define uma mensagem flash de sucesso
# - Autentica o usuário na sessão
# - Define o email do usuário na sessão
# - Redireciona para o caminho após o login bem-sucedido
  def successful_login
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    session[:email] = resource.email
    respond_with resource, location: after_sign_in_path_for(resource)
  end

##
# Cria uma nova sessão para o usuário autenticado (método auxiliar).
#
# Recebe os parâmetros de autenticação via \params[:pessoa].
# Exibe uma mensagem de erro caso a autenticação falhe.
#
# Não recebe argumentos diretos.
# Não há retorno.
#
# Efeitos colaterais:
# - Define uma mensagem flash de erro
# - Limpa as senhas do recurso
# - Renderiza a view de login com status 401 (não autorizado)
  def failed_login
    flash.now[:alert] = "Login ou senha inválidos"
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with_navigational(resource) { render :new, status: :unauthorized }
  end


  protected
##
# Permite que os parâmetros de login sejam configurados.
#
# Permite os parâmetros :email e :matricula.
# Esses parâmetros são usados para autenticar o usuário.
#
# Não recebe argumentos diretos.
# Não há retorno.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :matricula])
  end

##
# Define o caminho após o login bem-sucedido (método auxiliar).
#
# Redireciona o usuário para o dashboard após o login.
#
# Argumento:
# - resource: o recurso autenticado (usuário)
#
# Não há retorno explícito, mas redireciona o usuário para o caminho especificado.
#
# Efeitos colaterais:
# - Define uma mensagem flash de sucesso
  def after_sign_in_path_for(resource)
    flash[:notice] = "Login efetuado com sucesso"
    dashboard_path
  end

  private
##
# Define variáveis necessárias para o Devise.
#
# Usado nas views de login para exibir informações do usuário
#
# Não recebe argumentos diretos.
# Não há retorno.
#
# Efeitos colaterais:
# - Define a variável @resource com uma nova instância do recurso (usuário)
# - Define a variável @resource_name com o nome do recurso (pessoa)
# - Define a variável @devise_mapping com o mapeamento do Devise para o recurso
  def set_devise_vars
    @resource = resource_class.new(sign_in_params)
    @resource_name = resource_name
    @devise_mapping = Devise.mappings[:pessoa]
  end
end
