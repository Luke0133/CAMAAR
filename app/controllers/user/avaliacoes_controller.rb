# Controller responsável pela exibição e submissão de respostas aos
# formulários de avaliação para alunos e professores em suas respectivas turmas
class User::AvaliacoesController < ApplicationController
  layout "avaliacoes"

  def index
    aluno = current_pessoa

    turmas_ids = aluno.turmas.pluck(:id)

    respondidos_ids = aluno.formulario_respondidos.pluck(:formulario_id)

    @formularios = buscar_formularios_validos(turmas_ids, respondidos_ids)

    if Formulario.invalidos.any?
      puts "warning"
      flash.now[:alert] = "Um ou mais formulários estão incompatíveis e não podem ser visualizados"
    end 
  end

  def responder
    @formulario = Formulario.includes(ligacao_pergunta: :perguntas).find(params[:id])
    @perguntas = @formulario.ligacao_pergunta.perguntas.order(:id)
    render "responder_formulario"
  end

  def enviar_respostas
    @formulario = Formulario.find(params[:id])
    @perguntas = @formulario.ligacao_pergunta.perguntas

    respostas_params = params[:respostas] || {}

    if respostas_completas?(@perguntas, respostas_params) 
      salvar_respostas(@perguntas, respostas_params)
      FormularioRespondido.create!(formulario: @formulario, email: session[:email])
      redirect_to user_avaliacoes_path, notice: "Resposta enviada com sucesso"
    else
      flash.now[:alert] = "Todos os campos precisam ser preenchidos"
      render "responder_formulario", status: :unprocessable_entity
    end
  end
  
  def salvar_respostas(perguntas, respostas_params)
    perguntas.each do |pergunta|
      Resposta.create!(
        formulario: @formulario,
        pergunta: pergunta,
        conteudo: respostas_params[pergunta.id.to_s]
      )
    end
  end

  private
  
  # Retorna formulários válidos de um aluno, que ainda não foram respondidos
  def buscar_formularios_validos(turmas_ids, respondidos_ids)
    Formulario
      .includes(turma: :materia)
      .validos
      .where(turma_id: turmas_ids)
      .where.not(id: respondidos_ids)
  end

  def respostas_completas?(perguntas, respostas_params)
    perguntas.all? { |pergunta| respostas_params[pergunta.id.to_s].present? }
  end
end
