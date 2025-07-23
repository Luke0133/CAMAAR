##
# Controladora para a página de início do CAMAAR
#
# Sua única funcionalidade é verificar e redirecionar
# as pessoas dependendo da função (admin ou usuário)
#
class HomeController < ApplicationController

  ##
  # Redireciona para a página de gerenciamento caso a pessoa cadastrada seja um administrador.
  # Caso a pessoa seja apenas um aluno ou professor, ela é redirecionada para a página de avaliação. 
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Redireciona para a página de login caso usuário não esteja autenticado,
  #   exibindo uma mensagem +flash[:alert]+.
  # - Caso a pessoa cadastrada seja um administrador, redireciona para a página de gerenciamento
  # - Caso a pessoa cadastrada seja um aluno ou professor, redireciona para a página de avaliações
  #
  def index
    pessoa = current_pessoa
    # puts "PESSOA: #{pessoa}"

    funcoes = pessoa.cargos.pluck(:funcao)
    # puts "Funções do usuário: #{funcoes.inspect}"
    case
    when funcoes.include?(0)
      redirect_to admin_gerenciamento_path
    when funcoes.include?(1)
      redirect_to user_avaliacoes_path
    when funcoes.include?(2)
      redirect_to user_avaliacoes_path
    else
      redirect_to root_path, alert: "Você não tem permissão de acesso."
    end
  end
end