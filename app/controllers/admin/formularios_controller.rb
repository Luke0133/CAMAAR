class Admin::FormulariosController < ApplicationController
  layout "criar_formulario"
  def new
    @formulario = Formulario.new
    @templates = Template.all
    @materias = Materia.includes(:turmas).all
    @turmas_por_materia = @materias.index_with { |materia| materia.turmas.first }
  end

  def create
    @templates = Template.all
    @materias = Materia.includes(:turmas).all
    @turmas_por_materia = @materias.index_with { |materia| materia.turmas.first }

    if formulario_params[:template_id].blank?
      flash[:alert] = "Nenhum template selecionado"
      # redirect_to new_admin_formulario_path and return
      return render :new
    end

    if formulario_params[:materia_ids].blank?
      flash[:alert] = "Nenhuma matéria foi selecionada"
      # redirect_to new_admin_formulario_path and return
      return render :new
    end

    template = Template.find(formulario_params[:template_id])
    materia_ids = formulario_params[:materia_ids]

    created_forms = []

    materia_ids.each do |materia_id|
      materia = Materia.find(materia_id)
      turma = materia.turmas.first

      unless turma
        flash[:alert] = "A matéria #{materia.nome} não possui turmas"
        redirect_to new_admin_formulario_path and return
      end

      formulario = Formulario.new(
        ligacao_pergunta_id: template.ligacao_pergunta_id,
        turma_id: turma.id,
        nome: "#{template.nome}"
      )

      created_forms << formulario if formulario.save
    end

    if created_forms.any?
      flash[:notice] = "Formulário enviado com sucesso"
      redirect_to admin_gerenciamento_path
    else
      flash[:alert] = "Erro ao salvar os formulários"
      redirect_to new_admin_formulario_path
    end
  end

  private

  def formulario_params
    params.require(:formulario).permit(:template_id, materia_ids: [])
  end
end
