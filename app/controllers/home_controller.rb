class HomeController < ApplicationController
  def index
    pessoa = Pessoa.find_by(email: session[:email])

    if pessoa.nil?
      redirect_to new_session_path, alert: "Você precisa estar logado."
      return
    end

    funcoes = pessoa.cargos.pluck(:funcao)

    if funcoes.include?("admin")
      redirect_to admin_gerenciamento_path
    elsif funcoes.include?("usuario")
      redirect_to user_avaliacoes_path
    else
      redirect_to root_path, alert: "Você não tem permissão de acesso."
    end
  end
end