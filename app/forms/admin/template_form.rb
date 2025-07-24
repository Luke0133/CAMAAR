# frozen_string_literal: true

##
# Formulário responsável por criar ou atualizar um template e suas perguntas associadas.
#
# Utiliza ActiveModel para validações e atributos.
#
# Funcionalidades principais:
# - Validação dos dados do template e suas perguntas
# - Criação ou atualização do template no banco de dados
# - Associação entre template, perguntas e opções
#
module Admin
  class TemplateForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :nome, :string
    attribute :questions, default: []

    validates :nome, presence: { message: "O nome do template não pode estar em branco" }
    validate  :questions_presence_and_text
    validate  :options_presence_for_multiple_choice

    ##
    # Salva o template e suas perguntas no banco de dados.
    #
    # Argumentos:
    # - existing_template (Template, opcional): instância existente de Template a ser atualizada.
    #
    # Retorna:
    # - true se a operação foi bem-sucedida
    # - false em caso de falhas de validação ou exceções
    #
    # Efeitos colaterais:
    # - Cria ou atualiza registros no banco de dados:
    #   - LigacaoPergunta
    #   - Template
    #   - Pergunta
    #   - Opcao (quando necessário)
    #
    # Exemplo de uso:
    #   form = TemplateForm.new(nome: "Exemplo", questions: [...])
    #   form.save
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

    ##
    # Template gerado ou atualizado após o salvamento.
    #
    # Retorna:
    # - Instância de Template associada ao formulário.
    attr_reader :template

    private

    ##
    # Busca ou cria uma LigacaoPergunta associada ao template.
    #
    # Argumentos:
    # - existing_template (Template, opcional): template existente com ligação associada
    #
    # Retorna:
    # - LigacaoPergunta existente ou nova
    def find_or_create_ligacao(existing_template) # :doc:
      existing_template&.ligacao_pergunta || LigacaoPergunta.create!
    end

    ##
    # Cria ou atualiza o Template associado ao formulário.
    #
    # Argumentos:
    # - existing_template (Template, opcional): template a ser atualizado
    # - ligacao (LigacaoPergunta): ligação com perguntas
    #
    # Retorna:
    # - Template criado ou atualizado
    #
    # Efeitos colaterais:
    # - Atualiza o nome do template
    # - Remove perguntas antigas, se houver
    def build_or_update_template(existing_template, ligacao) # :doc:
      if existing_template
        existing_template.update!(nome: nome)
        ligacao.perguntas.destroy_all
        existing_template
      else
        Template.create!(nome: nome, ligacao_pergunta: ligacao)
      end
    end

    ##
    # Processa o array de perguntas e as associa à LigacaoPergunta.
    #
    # Argumentos:
    # - ligacao (LigacaoPergunta): ligação a ser preenchida com perguntas
    #
    # Efeitos colaterais:
    # - Cria registros de Pergunta e Opcao
    def process_questions(ligacao) # :doc:
      questions.each do |question_data|
        create_pergunta_with_opcoes(question_data, ligacao)
      end
    end

    ##
    # Cria uma Pergunta e, se necessário, suas opções.
    #
    # Argumentos:
    # - data (Hash): dados da pergunta (:text, :type, :options)
    # - ligacao (LigacaoPergunta): ligação à qual a pergunta será associada
    #
    # Efeitos colaterais:
    # - Cria registro de Pergunta no banco
    # - Cria registros de Opcao se o tipo da pergunta for múltipla escolha
    def create_pergunta_with_opcoes(data, ligacao) # :doc:
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

    ##
    # Transfere erros de validação de um model externo para o formulário.
    #
    # Argumentos:
    # - model (ActiveRecord::Base): instância com erros de validação
    #
    # Efeitos colaterais:
    # - Adiciona erros ao objeto de formulário
    def add_model_errors(model) # :doc:
      model.errors.each do |error|
        errors.add(error.attribute, error.message)
      end
    end

    ##
    # Valida presença de pelo menos uma pergunta e texto em todas.
    #
    # Retorna erro se:
    # - Não houver perguntas
    # - Alguma pergunta estiver sem texto
    def questions_presence_and_text # :doc:
      if questions.blank? || questions.any? { |q| q[:text].blank? }
        errors.add(:questions, "Deve haver pelo menos uma pergunta e todas devem ter texto")
      end
    end

    ##
    # Valida que todas as opções das perguntas de múltipla escolha estão preenchidas.
    #
    # Retorna erro se:
    # - Alguma opção estiver em branco para perguntas do tipo múltipla escolha (tipo 0)
    def options_presence_for_multiple_choice # :doc:
      if questions.any? { |q| q[:type].to_i.zero? && (q[:options] || []).any?(&:blank?) }
        errors.add(:options, "Todas as opções de todas as perguntas devem estar preenchidas")
      end
    end
  end
end