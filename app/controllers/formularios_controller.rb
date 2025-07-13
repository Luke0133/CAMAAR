class FormulariosController < ApplicationController
  def new
    @formulario = Formulario.new
    @templates = Template.all
    @materias = Materia.all
  end

  def create
    @templates = Template.all
    @materias = Materia.all

    if formulario_params[:template_id].blank?
      @template_error = "Nenhum template selecionado"
      @formulario = Formulario.new
      render :new and return
    end

    if formulario_params[:materia_id].blank?
      @materia_error = "Nenhuma matéria foi selecionada"
      @formulario = Formulario.new
      render :new and return
    end

    template = Template.find(formulario_params[:template_id])
    materia = Materia.find(formulario_params[:materia_id])
    turma = materia.turmas.first

    unless turma
      @materia_error = "A matéria selecionada não possui turmas"
      @formulario = Formulario.new
      render :new and return
    end

    @formulario = Formulario.new(
      ligacao_pergunta_id: template.ligacao_pergunta_id,
      turma_id: turma.id,
      nome: "Formulário para #{turma.semestre} - Turma #{turma.numero_turma}"
    )

    if @formulario.save
      @formulario_enviado = true
      flash[:notice] = "Formulário enviado com sucesso"
      redirect_to new_formulario_path, notice: "Formulário enviado com sucesso"
    else
      render :new
    end
  end

  private

  def formulario_params
    params.require(:formulario).permit(:template_id, :materia_id)
  end
end
