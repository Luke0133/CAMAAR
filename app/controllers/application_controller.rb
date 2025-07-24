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
  # Redireciona para a página de login caso a pessoa não esteja autenticada.
  # Impede pessoas não autenticadas de acessarem qualquer outra rota
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Redireciona para a página de login caso pessoa não esteja autenticada
  # - Exibe uma mensagem +flash[:error]+ caso pessoa tenha sido redirecionada
  #
  def require_login # :doc:
    unless current_pessoa
      flash[:error] = "Você precisa estar logado para acessar esta página."
      redirect_to login_path
    end
  end

  ##
  # Redireciona para a página de dashboard caso acesse área restrita.
  #
  # Usuários somente acessam páginas no domínio user, então se não possuirem
  # cargo admin, não podem acessar páginas do domínio admin
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Redireciona para a página de dashboard caso usuário não tenha permissões
  # - Exibe uma mensagem +flash[:error]+ caso usuário tenha sido redirecionado
  #
  def authorize_admin!
    unless admin?
      flash[:error] = "Você não tem permissão para acessar essa área administrativa."
      redirect_to dashboard_path
    end
  end

  ##
  # Redireciona para a página de dashboard caso acesse área restrita.
  #
  # Admins somente acessam páginas no domínio admin, então se não possuirem
  # cargo de aluno ou professor, não podem acessar páginas do domínio user
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Redireciona para a página de dashboard caso admin não tenha permissões
  # - Exibe uma mensagem +flash[:error]+ caso admin tenha sido redirecionado
  #
  def authorize_usuario!
    unless usuario?
      flash[:error] = "Você não tem permissão para acessar essa área de usuário."
      redirect_to dashboard_path
    end
  end


  ##
  # Verifica se pessoa possui cargo de administrador
  #
  # Não recebe argumentos.
  #
  # Retorna:
  # [Bool] true se possuir cargo de admin
  #
  # Não possui efeitos colaterais.
  #
  def admin?
    current_pessoa&.cargos&.any? { |cargo| cargo.funcao == 0 }
  end

  ##
  # Verifica se pessoa possui cargo de usuário (aluno ou professor)
  #
  # Não recebe argumentos.
  #
  # Retorna:
  # [Bool] true se possuir cargo de usuário 
  #
  # Não possui efeitos colaterais.
  #
  def usuario?
    current_pessoa&.cargos&.any? { |cargo| [1, 2].include?(cargo.funcao) }
  end
end