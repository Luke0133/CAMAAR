##
# Controladora base da aplicação, herdada por todos as demais controladoras.
#
# Define funcionalidades comuns usados na demais controladoras, como:
# - Verificação de login
# - Definição de idioma (locale)
# - Método auxiliar de autenticação: +current_pessoa+
#
class ApplicationController < ActionController::Base
  allow_browser versions: :modern  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  helper_method :current_pessoa

  before_action :set_locale
  before_action :require_login, unless: :devise_controller?

  ##
  # Retorna a pessoa autenticada na sessão atual com base no e-mail.
  #
  # Depende de +session[:email]+ para identificar o usuário.
  #
  # Não recebe argumentos.
  #
  # Retorna:
  # [Pessoa, nil] objeto Pessoa autenticado ou nil se não houver sessão ativa.
  #
  # Efeito colateral:
  # - Usa memoização para evitar múltiplas consultas ao banco na mesma requisição
  #
  def current_pessoa
    @current_pessoa ||= Pessoa.find_by(email: session[:email])
  end

  private

  ##
  # Define o idioma da aplicação como português (:pt).
  #
  # É executado antes de cada requisição.
  # 
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeito colateral:
  # - Altera o valor de +I18n.locale+ globalmente para esta requisição,
  #   afetando a exibição de textos traduzidos.
  #
  def set_locale # :doc:
    I18n.locale = :pt
  end

  ##
  # Redireciona para a página de login caso o usuário não esteja autenticado.
  # Impede pessoas não autenticadas de acessarem qualquer outra rota
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Redireciona para a página de login caso usuário não esteja autenticado
  # - Exibe uma mensagem +flash[:alert]+ caso usuário tenha sido redirecionado
  #
  def require_login # :doc:
    unless current_pessoa
      redirect_to login_path, alert: "Você precisa estar logado para acessar esta página."
    end
  end
end