# frozen_string_literal: true

module Admin
  class TemplatesController < ApplicationController
    layout "templates"

    before_action :set_template,             only: %i[edit update]
    before_action -> { set_template(true) }, only: %i[destroy]

    def index
      @valid_templates   = Template
                             .joins(ligacao_pergunta: :perguntas)
                             .distinct
                             .includes(ligacao_pergunta: :perguntas)
      @invalid_templates = Template.all - @valid_templates
      @show_incompatibility_message = @valid_templates.count != Template.count
    end

    def new
      @template  = Template.new
      @name      = ""
      @questions = []
    end

    def create
      @form = TemplateForm.new(template_form_params)

      if @form.save
        flash[:success] = "Template criado com sucesso!"
        redirect_to admin_templates_path
      else
        render_with_errors(@form, :new)
      end
    end

    def edit
      @name      = @template.nome
      @questions = questions_for_edit(@template)
    end

    def update
      @form = TemplateForm.new(template_form_params)

      if @form.save(@template)
        flash[:success] = "Template atualizado com sucesso!"
        redirect_to admin_templates_path
      else
        render_with_errors(@form, :edit)
      end
    end

    def destroy
      nome = @template.nome
      @template.destroy!
      flash[:warning] = "O template \"#{nome}\" foi excluído!"
      redirect_to admin_templates_path
    end

    private

    def set_template
    def set_template(is_delete = false)
      @template = Template.find_by(id: params[:id])
      return if @template

      action = is_delete ? 'excluir' : 'editar'
      flash[:error] = "Falha ao #{action}: o template selecionado não existe."
      redirect_to admin_templates_path
    end

    def template_form_params
      permitted = params.require(:template).permit(:nome)
      {
        nome:      permitted[:nome],
        questions: build_questions_array
      }
    end

    def build_questions_array
      Array(params[:questions]).map do |question_data|
        {
          text:    question_data[:text].to_s.strip,
          type:    question_data[:type],
          options: Array(question_data[:options])
        }
      end
    end

    def render_with_errors(form, action_name)
      @name      = form.nome
      @questions = form.questions.map { |dq| map_question_payload(dq) }
      @template ||= Template.new(nome: @name)

      flash.now[:error] = "Erro(s) no template: " +
                          form.errors.map(&:message).join("; ") + "."

      render action_name, layout: "templates", status: :unprocessable_entity
    end

    def map_question_payload(question_data)
      {
        pergunta: question_data[:text],
        tipo:     question_data[:type].to_i,
        opcoes:   Array(question_data[:options]).map { |opt| { opcao: opt } }
      }
    end

    def questions_for_edit(template)
      template
        .ligacao_pergunta
        .perguntas
        .includes(:opcoes)
        .order(:id)
        .map { |record| map_edit_question(record) }
    end

    def map_edit_question(record)
      {
        pergunta: record.pergunta,
        tipo:     record.tipo.to_s,
        opcoes:   record.opcoes.order(:item).map { |op| { opcao: op.opcao } }
      }
    end
  end
end
