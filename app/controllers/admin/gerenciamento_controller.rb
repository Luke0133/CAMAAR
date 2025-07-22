class Admin::GerenciamentoController < ApplicationController
  layout "gerenciamento"

  # GET /admin/gerenciamento
  def index
    @can_edit_templates = Pessoa.joins(:cargos).where(cargos: { funcao: [1, 2] }).exists?
    @can_send_formularios = Template.exists?
    @can_view_resultados = Formulario.exists?
  end

  def importar
    file = params[:file]

    if !valid_file?(file)
      return redirect_to_error("Falha ao importar dados: arquivo com extensão incorreta")
    end

    process_file(file)
  end

  private

  def valid_file?(file)
    file.present? && File.extname(file.original_filename) == ".json"
  end

  def process_file(file)
    json_data = JSON.parse(file.read)
    houve_atualizacao = ImportadorSigaa.new(json_data).processar

    mensagem = houve_atualizacao ? 
      "Dados importados com sucesso: alguns dados foram atualizados" :
      "Dados importados com sucesso"

    redirect_to admin_gerenciamento_path, notice: mensagem
  rescue JSON::ParserError, ActiveRecord::RecordInvalid, ActiveRecord::NotNullViolation, SQLite3::ConstraintException
    redirect_to_error("Falha ao importar dados: dados do arquivo em formato inválido")
  rescue => exception
    Rails.logger.error "[IMPORT ERROR] #{exception.class}: #{exception.message}"
    redirect_to_error("Falha ao importar dados: erro inesperado")
  end

  def redirect_to_error(message)
    redirect_to admin_gerenciamento_path, alert: message
  end
end
