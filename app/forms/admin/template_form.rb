# frozen_string_literal: true

module Admin
  class TemplateForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :nome, :string
    attribute :questions, default: []

    validates :nome, presence: { message: "O nome do template não pode estar em branco." }
    validate  :questions_presence_and_text
    validate  :options_presence_for_multiple_choice

    def save(existing_template = nil)
      return false unless valid?

      ActiveRecord::Base.transaction do
        ligacao = find_or_create_ligacao(existing_template)
        template = build_or_update_template(existing_template, ligacao)
        process_questions(ligacao)

        @template = template
      end

      true
    rescue ActiveRecord::RecordInvalid => error                 
      add_model_errors(error.record)                              
      false
    end

    attr_reader :template

    private

    def find_or_create_ligacao(existing_template)
      existing_template&.ligacao_pergunta || LigacaoPergunta.create!
    end

    def build_or_update_template(existing_template, ligacao)
      if existing_template
        existing_template.update!(nome: nome)
        ligacao.perguntas.destroy_all
        existing_template
      else
        Template.create!(nome: nome, ligacao_pergunta: ligacao)
      end
    end

    def process_questions(ligacao)
      questions.each do |question_data|
        create_pergunta_with_opcoes(question_data, ligacao)
      end
    end

    def create_pergunta_with_opcoes(data, ligacao)
      tipo = data[:type].to_i
      pergunta = Pergunta.create!(
        ligacao_pergunta: ligacao,
        tipo: tipo,
        pergunta: data[:text]
      )

      return unless tipo.zero?

      data[:options].reject(&:blank?).each_with_index do |option, index|
        Opcao.create!(
          pergunta: pergunta,
          item: index + 1,
          opcao: option
        )
      end
    end

    def add_model_errors(model)
      model.errors.each do |error|
        errors.add(error.attribute, error.message)
      end
    end

    def questions_presence_and_text
      if questions.blank? || questions.any? { |q| q[:text].blank? }
        errors.add(:questions, "Deve haver pelo menos uma pergunta e todas devem ter texto")
      end
    end

    def options_presence_for_multiple_choice
      if questions.any? { |q| q[:type].to_i.zero? && (q[:options] || []).any?(&:blank?) }
        errors.add(:options, "Todas as opções de todas as perguntas devem estar preenchidas")
      end
    end
  end
end
