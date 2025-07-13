class Admin::ResultadosController < ApplicationController
  layout "resultados"

  # GET /admin/resultados
  def index
    @forms = Formulario.validos

    if Formulario.invalidos.any?
      flash.now[:error] = "Um ou mais formulários estão incompatíveis e não podem ser visualizados."
    end
  end
end