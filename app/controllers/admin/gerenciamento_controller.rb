##
# Controladora para a página de gerenciamento do sistema.
#
# Permite que administradores importem dados do SIGAA por meio do botão "Importar dados" e possui
# botões de redirecionamento para as funcionalidades de gerenciamento de templates, de formulários
# e de visualização de resultados.
#
# Herda de +ApplicationController+ para funcionalidades comuns como autenticação e definição de idioma.
#
class Admin::GerenciamentoController < ApplicationController
  layout "gerenciamento"

  # GET /admin/gerenciamento
  def index
    @can_edit_templates = Pessoa.joins(:cargos).where(cargos: { funcao: [1, 2] }).exists?
    @can_send_formularios = Template.exists?
    @can_view_resultados = Formulario.exists?
  end

  # POST /admin/gerenciamento/importar
  ##
  # Recebe um arquivo JSON enviado pelo formulário de importação, verifica se este é válido
  # e processa os dados para atualizar ou criar registros no banco de dados.
  #
  # Redireciona para a página de gerenciamento com uma mensagem de sucesso ou erro.
  #
  # Argumentos:
  # - [:file]: recebido como parâmetro, é um arquivo JSON contendo os dados a serem importados.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Criação ou atualização de registros de pessoa, cargo, participantes, matéria e turma no 
  # banco de dados com os dados importados.
  #
  def importar
    file = params[:file]

    if !valid_file?(file)
      return redirect_to admin_gerenciamento_path, alert:"Falha ao importar dados: arquivo com extensão incorreta"
    end

    process_file(file)
  end

  private

  ##
  # Verifica se o arquivo enviado é válido, ou seja, se não está vazio e se a extensão é .json.
  #
  # Argumentos:
  # - file: arquivo enviado pelo formulário.
  #  
  # Retorna:
  # - [Boolean] true se o arquivo é válido, false caso contrário.
  #
  def valid_file?(file)
    file.present? && File.extname(file.original_filename) == ".json"
  end

  ##
  # Processa o arquivo JSON recebido, fazendo parse dos dados e passando para o importador
  # de SIGAA, que irá criar ou atualizar os registros correspondentes no banco de dados, ou
  # apresentar uma mensagem de erro caso ocorra algum problema.
  #
  # Argumentos:
  # - file: arquivo JSON contendo os dados a serem importados.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Criação ou atualização de registros de pessoa, cargo, participantes, matéria e turma no 
  # banco de dados com os dados importados.
  # - Redireciona para a página de gerenciamento com uma mensagem de sucesso ou erro
  #
  def process_file(file)
    json_data = JSON.parse(file.read)
    
    ImportadorSigaa.new(json_data).processar      

    redirect_to admin_gerenciamento_path, notice: "Dados importados com sucesso"
  rescue JSON::ParserError, ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation, SQLite3::ConstraintException
    redirect_to admin_gerenciamento_path, alert:"Falha ao importar dados: dados do arquivo em formato inválido"
  rescue => exception
    Rails.logger.error "[IMPORT ERROR] #{exception.class}: #{exception.message}"
    redirect_to_error("Falha ao importar dados: erro inesperado")
  end

  ##
  # Redireciona para a página de gerenciamento com uma mensagem de erro.
  #
  # Argumentos:
  # - message: mensagem de erro a ser exibida.
  # 
  # Não há retorno.
  #
  def redirect_to_error(message)
    redirect_to admin_gerenciamento_path, alert: message
  end

  def redefinir_senha
    pessoa = current_pessoa
    if pessoa
      enviar_email_redefinicao(pessoa)
      redirect_back(fallback_location: admin_gerenciamento_path, notice: "Email de redefinição de senha enviado com sucesso!")
    else
      redirect_back(fallback_location: admin_gerenciamento_path, alert: "Erro ao enviar email de redefinição.")
    end
  end

  private

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
