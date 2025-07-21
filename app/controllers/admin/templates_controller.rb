# frozen_string_literal: true

module Admin
  class TemplatesController < ApplicationController
    layout "templates_fill", only: %i[new edit index]

    before_action :set_template, only: %i[edit update]

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
      puts params[:questions].inspect
      @form = TemplateForm.new(template_form_params)

      if @form.save
        redirect_to admin_templates_path,
                    notice: "Template Criado Com Sucesso"
      else
        render_with_errors(@form, :new)
      end
    end

    def edit
      @name      = @template.nome
      @questions = questions_for_edit(@template)
    end

    def update
      puts params[:questions].inspect
      @form = TemplateForm.new(template_form_params)

      if @form.save(@template)
        redirect_to admin_templates_path,
                    notice: "Template atualizado com sucesso"
      else
        render_with_errors(@form, :edit)
      end
    end

    def destroy
      template = Template.find_by(id: params[:id])
      if template
        nome = template.nome
        template.destroy!
        redirect_to admin_templates_path,
                    notice: "O #{nome} foi excluído!"
      else
        redirect_to admin_templates_path,
                    alert: "Falha ao excluir: o template selecionado não existe."
      end
    end

    private

    def set_template
      @template = Template.find_by(id: params[:id])
      return if @template

      redirect_to admin_templates_path,
                  alert: "Falha ao editar: o template selecionado não existe."
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

      render action_name, layout: "templates_fill", status: :unprocessable_entity
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

