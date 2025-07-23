class Admin::FormulariosController < ApplicationController
  layout "criar_formulario"

  def new
    carregar_dados_formulario     
    @formulario = Formulario.new        
  end

  def create
    carregar_dados_formulario

    return render_erro(:template, "Nenhum template selecionado") if template_id_blank?
    return render_erro(:materia, "Nenhuma matéria foi selecionada") if materia_ids_blank?

    template = Template.find(formulario_params[:template_id])
    created_forms = criar_formularios_para_materias(template)

    if created_forms.any?
      flash[:notice] = "Formulário enviado com sucesso"
      redirect_to admin_gerenciamento_path
    else
      flash.now[:alert] ||= "Erro ao salvar os formulários"                  
      render :new                                                        
    end
  end

  private

  def carregar_dados_formulario
    @templates = Template.all
    @materias = Materia.includes(:turmas).all
    @turmas_por_materia = @materias.index_with { |materia| materia.turmas.first }
  end

  def template_id_blank?
    formulario_params[:template_id].blank?
  end

  def materia_ids_blank?
    formulario_params[:materia_ids].blank?
  end

  def render_erro(tipo, mensagem)
    flash.now[:alert] = mensagem
    render :new
  end

  def criar_formularios_para_materias(template)
    formulario_params[:materia_ids].filter_map do |materia_id|
      criar_formulario_para_materia(template, materia_id)
    end
  end

  def criar_formulario_para_materia(template, materia_id)
    materia = Materia.find(materia_id)
    turma = materia.turmas.first

    return sem_turma_alerta(materia) unless turma

    formulario = construir_formulario(template, turma)
    formulario.save ? formulario : nil
  end

  def sem_turma_alerta(materia)
    flash.now[:alert] = "A matéria #{materia.nome} não possui turmas"               
    nil                                                                             
  end

  def construir_formulario(template, turma)
    Formulario.new(
      ligacao_pergunta_id: template.ligacao_pergunta_id,
      turma_id: turma.id,
      nome: template.nome
    )
  end

  def formulario_params
    params.require(:formulario).permit(:template_id, materia_ids: [])
  end
end