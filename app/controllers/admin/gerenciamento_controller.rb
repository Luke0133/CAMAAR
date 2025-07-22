class Admin::GerenciamentoController < ApplicationController
  layout "gerenciamento"

  # GET /admin/gerenciamento
  def index
    @can_edit_templates = Pessoa.joins(:cargos).where(cargos: { funcao: 1}).exists? or Pessoa.joins(:cargos).where(cargos: { funcao: 2}).exists?
    @can_send_formularios = Template.exists?
    @can_view_resultados = Formulario.exists?
  end

  def importar
    file = params[:file]

    unless file && File.extname(file.original_filename) == ".json"
      redirect_to admin_gerenciamento_path, alert: "Falha ao importar dados: arquivo com extensão incorreta" and return
    end

    begin
      json_data = JSON.parse(file.read)
      houve_atualizacao = ImportadorSigaa.new(json_data).processar

      mensagem = houve_atualizacao ? 
        "Dados importados com sucesso: alguns dados foram atualizados" : 
        "Dados importados com sucesso"

      redirect_to admin_gerenciamento_path, notice: mensagem
    rescue JSON::ParserError
      redirect_to admin_gerenciamento_path, alert: "Falha ao importar dados: dados do arquivo em formato inválido"
    rescue ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation, SQLite3::ConstraintException
      redirect_to admin_gerenciamento_path, alert: "Falha ao importar dados: dados do arquivo em formato inválido"
    rescue => e
      Rails.logger.error "[IMPORT ERROR] #{e.class}: #{e.message}"
      redirect_to admin_gerenciamento_path, alert: "Falha ao importar dados: erro inesperado"
    end
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
