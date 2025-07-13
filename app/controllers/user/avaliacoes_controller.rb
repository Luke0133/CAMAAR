class User::AvaliacoesController < ApplicationController
  layout "avaliacoes"

  def index
    aluno = Pessoa.find_by(email: session[:email])

    turmas_ids = aluno.turmas.pluck(:id)

    respondidos_ids = aluno.formulario_respondidos.pluck(:formulario_id)

    @formularios = Formulario
      .includes(:turma => :materia)
      .validos
      .where(turma_id: turmas_ids)
      .where.not(id: respondidos_ids)
    

    invalid_forms = Formulario.invalidos
    if invalid_forms.any?
      puts "warning"
      flash.now[:alert] = "Um ou mais formulários estão incompatíveis e não podem ser visualizados"
    end
  end
end
