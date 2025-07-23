<<<<<<< HEAD
##
# Controladora responsável pela exibilçao e submissão de avaliações para usuários.
#
# Usa o layout personalizado "avaliacoes".
#
# Funcionalidades principais:
#
# - Listar formulários válidos
# - Exibir aviso caso existam formulários inválidos
# - Visão de formulários referentes a turmas das quais o usuário participa
# - Submissão de formulários respondidos
#
class User::AvaliacoesController < ApplicationController
  layout "avaliacoes"

  ##
  # Exibe a lista de formulários válidos das turmas em que o usuário é um participante
  # que ainda não foram respondidos
  #
  # Caso existam formulários inválidos, exibe uma mensagem de erro informando
  # que há formulários que não podem ser visualizados.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Atribui formulários válidos à variável de instância @formularios
  # - Exibe uma mensagem flash alert caso existam formulários inválidos
  #
  # Exemplo de uso:
  #   GET /user/avaliacoes
  def index
    aluno = current_pessoa

    turmas_ids = aluno.turmas.pluck(:id)

    respondidos_ids = aluno.formulario_respondidos.pluck(:formulario_id)

    @formularios = buscar_formularios_validos(turmas_ids, respondidos_ids)

    if Formulario.invalidos.any?
      # puts "warning"
      flash.now[:alert] = "Um ou mais formulários estão incompatíveis e não podem ser visualizados"
    end 
  end

  ##
  # Exibe as perguntas referentes a um formulário, permitindo que o usuário o responda.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Atribui informações sobre o formulário à variável de instância @formulario
  # - Atribui informações quanto às perguntas do formulário à variável de instância @perguntas
  # - Renderiza view "responder_formulario"
  #
  # Exemplo de uso:
  #   GET /user/avaliacoes/:id/responder  # em que o id é o identificador do formulário
  def responder
    @formulario = Formulario.includes(ligacao_pergunta: :perguntas).find(params[:id])
    @perguntas = @formulario.ligacao_pergunta.perguntas.order(:id)
    render "responder_formulario"
  end
  
  ##
  # Envia as respostas do usuário.
  #
  # Caso existam formulários inválidos, exibe uma mensagem de erro informando
  # que há formulários que não podem ser visualizados.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Atribui informações sobre o formulário à variável de instância @formulario
  # - Atribui informações quanto às perguntas do formulário à variável de instância @perguntas
  # - Exibe uma mensagem flash[:alert] caso existam campos não respondidos
  #   e renderiza novamente a página para mostrar tal mensagem
  # - Caso todos os campos tenham sido preenchidos/selecionados, guarda as respostas no banco de dados
  #   e que o usuário respondeu a esse formulário, retornando-o para a página de avaliações posteriormente
  #
  # Exemplo de uso:
  #   POST /user/avaliacoes/:id/enviar_respostas # em que id é o identificador do formulário
  def enviar_respostas
    @formulario = Formulario.find(params[:id])
    @perguntas = @formulario.ligacao_pergunta.perguntas

    respostas_params = params[:respostas]

    if respostas_completas?(@perguntas, respostas_params) 
      salvar_respostas(@perguntas, respostas_params)
      FormularioRespondido.create!(formulario: @formulario, email: session[:email])
      redirect_to user_avaliacoes_path, notice: "Resposta enviada com sucesso"
    else
      flash.now[:alert] = "Todos os campos precisam ser preenchidos"
      render "responder_formulario", status: :unprocessable_entity
    end
  end

  def redefinir_senha
    pessoa = current_pessoa
    if pessoa
      enviar_email_redefinicao(pessoa)
      redirect_back(fallback_location: user_avaliacoes_path, notice: "Email de redefinição de senha enviado com sucesso!")
    else
      redirect_back(fallback_location: user_avaliacoes_path, alert: "Erro ao enviar email de redefinição.")
    end
  end
  
  private

  ##
  # Salva respostas no banco de dados.
  #
  # Argumentos:
  # [Pergunta] perguntas: lista de objetos contendo perguntas do formulário
  # [ActionController::Parameters] respostas: hash contendo as respostas a cada pergunta
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Guarda as respostas no banco de dados
  #
  # Exemplo de uso:
  #   salvar_respostas(@perguntas, respostas_params) # Como no código de enviar_respostas
  def salvar_respostas(perguntas, respostas_params) #:doc:
    perguntas.each do |pergunta|
      Resposta.create!(
        formulario: @formulario,
        pergunta: pergunta,
        conteudo: respostas_params[pergunta.id.to_s]
      )
    end
  end
  
  ##
  # Retorna formulários válidos de um aluno, que ainda não foram respondidos
  #
  # Argumentos:
  # [int] turmas_ids: lista das chaves referentes às turmas (do usuário)
  # [int] respondidos_ids: listas das chaves referentes aos formulários respondidos pelo usuário
  #
  # Retorna:
  # [Formulario] lista de formulários ainda não respondidos
  #
  # Não há efeitos colaterais.
  #
  # Exemplo de uso:
  #   buscar_formularios_validos(turmas_ids, respondidos_ids) # Como no código de index
  def buscar_formularios_validos(turmas_ids, respondidos_ids) #:doc:
    Formulario
      .includes(turma: :materia)
      .validos
      .where(turma_id: turmas_ids)
      .where.not(id: respondidos_ids)
  end

  ##
  # Verifica se, para toda pergunta, existe uma resposta
  #
  # Argumentos:
  # [Pergunta] perguntas: lista de objetos contendo perguntas do formulário
  # [ActionController::Parameters] respostas: hash contendo as respostas a cada pergunta
  #
  # Retorna:
  # [TrueClass / FalseClass] true se todas as perguntas possuem resposta, false, caso o contrário
  #
  # Não há efeitos colaterais.
  #
  # Exemplo de uso:
  #   respostas_completas?(@perguntas, respostas_params) # Como no código de enviar_respostas
  def respostas_completas?(perguntas, respostas_params) #:doc:
    perguntas.all? { |pergunta| respostas_params[pergunta.id.to_s].present? }
  end

  def enviar_email_redefinicao(pessoa)
    time = Time.current

    raw_token, enc_token = Devise.token_generator.generate(Pessoa, :reset_password_token)
    pessoa.update!(reset_password_token: enc_token, reset_password_sent_at: time)
    Devise::Mailer.reset_password_instructions(pessoa, raw_token).deliver_now

    url = Rails.application.routes.url_helpers.edit_pessoa_password_url(
      reset_password_token: raw_token,
      host: request.host_with_port
    )

    File.open(Rails.root.join("log", "emails_enviados.log"), "a") do |arquivo_log|
      arquivo_log.puts "[#{time}] Redefinição solicitada para #{pessoa.email} - Token: #{raw_token} - URL: #{url}"
    end
  end
end
=======
class User::AvaliacoesController < ApplicationController
  layout "avaliacoes"

  def index
    aluno = current_pessoa

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

  def responder
    @formulario = Formulario.includes(ligacao_pergunta: :perguntas).find(params[:id])
    @perguntas = @formulario.ligacao_pergunta.perguntas.order(:id)
    render "responder_formulario"
  end

  def enviar_respostas
    @formulario = Formulario.find(params[:id])
    @perguntas = @formulario.ligacao_pergunta.perguntas

    respostas_params = params[:respostas] || {}

    if @perguntas.all? { |p| respostas_params[p.id.to_s].present? }
      @perguntas.each do |pergunta|
        Resposta.create!(
          formulario: @formulario,
          pergunta: pergunta,
          conteudo: respostas_params[pergunta.id.to_s]
        )
      end

      FormularioRespondido.create!(formulario: @formulario, email: session[:email])
      redirect_to user_avaliacoes_path, notice: "Resposta enviada com sucesso"
    else
      flash.now[:alert] = "Todos os campos precisam ser preenchidos"
      render "responder_formulario", status: :unprocessable_entity
    end
  end

end
>>>>>>> 3059227 (Adicionando documentação)
