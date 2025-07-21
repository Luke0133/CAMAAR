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
end
