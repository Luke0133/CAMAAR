class Admin::ResultadosController < ApplicationController
  layout "resultados"

  # GET /admin/resultados
  def index
    @forms = Formulario.validos

    if Formulario.invalidos.any?
      flash.now[:error] = "Um ou mais formulários estão incompatíveis e não podem ser visualizados."
    end
  end

  # GET /admin/resultados/:id/preparar_download
  def preparar_download
    formulario = Formulario.find(params[:id])

    if formulario.respostas.empty?
      flash[:warning] = "Este formulário ainda não contém respostas"
      return redirect_to admin_resultados_path
    else
      flash[:success] = "Arquivo de resultado baixado com sucesso"
      flash[:download_form_id] = formulario.id
    end
    redirect_to admin_resultados_path
  end

  # GET /admin/resultados/:id/download
  def download
    formulario = Formulario.find(params[:id])
    csv_data = formulario.generate_csv
    turma = formulario.turma
    materia = turma&.materia

    send_data csv_data, filename: "respostas_#{formulario.nome}_#{materia&.nome}_#{turma&.semestre}_turma-#{turma&.numero_turma}.csv", type: "text/csv"
  end
end