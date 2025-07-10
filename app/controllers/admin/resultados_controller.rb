class Admin::ResultadosController < ApplicationController
  layout "resultados"

  # GET /admin/resultados
  def index
    @answered_forms = Formulario.respondidos
    @invalid_forms = Formulario.invalidos

    @show_incompatibility_message = @invalid_forms.any?
  end
end