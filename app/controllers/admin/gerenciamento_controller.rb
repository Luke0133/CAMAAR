class Admin::GerenciamentoController < ApplicationController
    layout "gerenciamento"

    # GET /admin/gerenciamento
    def index
    end

    def importar
        file = params[:file]

        unless file && File.extname(file.original_filename) == ".json"
            redirect_to admin_gerenciamento_path, alert: "Erro ao importar dados: tipo de arquivo não suportado"
            return
        end

        begin
            json_data = JSON.parse(file.read)
            ImportadorSigaa.new(json_data).processar
            redirect_to admin_gerenciamento_path, notice: "Dados importados com sucesso"
        rescue JSON::ParserError
            redirect_to admin_gerenciamento_path, alert: "Erro ao importar dados: dados do arquivo em formato inválido"
        rescue => e
            redirect_to admin_gerenciamento_path, alert: "Erro ao importar dados: #{e.message}"
        end
    end
end
