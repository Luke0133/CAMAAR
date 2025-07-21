<<<<<<< HEAD
# frozen_string_literal: true

##
# Controladora responsável pela gestão de templates no painel administrativo.
#
# Usa o layout "templates" nas ações (new[TemplatesController.html#method-i-new], edit[TemplatesController.html#method-i-edit] e index[TemplatesController.html#method-i-index]).
#
# Funcionalidades principais:
#
# - Listar templates válidos e inválidos
# - Criar, editar e excluir templates
# - Processar perguntas associadas a um template
#
module Admin
  class TemplatesController < ApplicationController
    layout "templates"

    before_action :set_template,             only: %i[edit update]
    before_action -> { set_template(true) }, only: %i[destroy]

    ##
    # Lista os templates válidos e inválidos.
    #
    # Templates válidos são aqueles com ligação a perguntas.
    #
    # Não recebe argumentos.
    #
    # Não há retorno.
    #
    # Efeitos colaterais:
    # - Atribui os templates válidos e inválidos a variáveis de instância
    # - Define uma flag para exibir ou não uma mensagem de incompatibilidade
    #
    # Exemplo de uso:
    #   GET /admin/templates
    def index
      @valid_templates   = Template
                             .joins(ligacao_pergunta: :perguntas)
                             .distinct
                             .includes(ligacao_pergunta: :perguntas)
      @invalid_templates = Template.all - @valid_templates
      @show_incompatibility_message = @valid_templates.count != Template.count
    end

    ##
    # Inicializa um novo template em branco.
    #
    # Não recebe argumentos.
    #
    # Não há retorno.
    #
    # Efeitos colaterais:
    # - Atribui uma nova instância de Template à variável @template
    # - Inicializa @name e @questions para preenchimento no formulário
    #
    # Exemplo de uso:
    #   GET /admin/templates/new
    def new
      @template  = Template.new
      @name      = ""
      @questions = []
    end

    ##
    # Cria um novo template a partir dos parâmetros recebidos.
    #
    # Recebe parâmetros via \params[:template] e \params[:questions].
    #
    # Retorna:
    # - Redireciona para a listagem com mensagem de sucesso se a criação for bem-sucedida
    # - Renderiza o formulário novamente com mensagens de erro em caso de falha
    #
    # Efeitos colaterais:
    # - Cria novo registro de Template e associa perguntas
    def create
      @form = TemplateForm.new(template_form_params)

      if @form.save
        flash[:success] = "Template criado com sucesso!"
        redirect_to admin_templates_path
      else
        render_with_errors(@form, :new)
      end
    end

    ##
    # Exibe o formulário para edição de um template existente.
    #
    # Não recebe argumentos diretamente (template é buscado via filtro[TemplatesController.html#method-i-set_template]).
    #
    # Não há retorno.
    #
    # Efeitos colaterais:
    # - Define variáveis de instância com os dados do template a ser editado
    #
    # Exemplo de uso:
    #   GET /admin/templates/:id/edit
    def edit
      @name      = @template.nome
      @questions = questions_for_edit(@template)
    end

    ##
    # Atualiza os dados de um template existente.
    #
    # Recebe parâmetros via \params[:template] e \params[:questions].
    #
    # Retorna:
    # - Redireciona com mensagem de sucesso se a atualização for bem-sucedida
    # - Renderiza o formulário novamente com mensagens de erro em caso de falha
    #
    # Efeitos colaterais:
    # - Altera dados de um template existente
    def update
      @form = TemplateForm.new(template_form_params)

      if @form.save(@template)
        flash[:success] = "Template atualizado com sucesso!"
        redirect_to admin_templates_path
      else
        render_with_errors(@form, :edit)
      end
    end

    ##
    # Exclui um template do sistema.
    #
    # Não recebe argumentos diretamente (template é buscado via filtro[TemplatesController.html#method-i-set_template]).
    #
    # Retorna:
    # - Redireciona para a listagem com mensagem de sucesso
    #
    # Efeitos colaterais:
    # - Remove o registro do banco de dados
    def destroy
      nome = @template.nome
      @template.destroy!
      flash[:warning] = "O template \"#{nome}\" foi excluído!"
      redirect_to admin_templates_path
    end

    private

    ##
    # Define a instância do template com base no parâmetro \params[:id].
    #
    # Efeitos colaterais:
    # - Redireciona com mensagem de erro caso o template não exista
    def set_template(is_delete = false) # :doc:
      @template = Template.find_by(id: params[:id])
      return if @template

      action = is_delete ? 'excluir' : 'editar'
      flash[:error] = "Falha ao #{action}: o template selecionado não existe."
      redirect_to admin_templates_path
    end

    ##
    # Monta os parâmetros esperados pelo form object TemplateForm.
    #
    # Retorna um hash com:
    # - :nome => string
    # - :questions => array de hashes com dados das perguntas
    def template_form_params # :doc:
      permitted = params.require(:template).permit(:nome)
      {
        nome:      permitted[:nome],
        questions: build_questions_array
      }
    end

    ##
    # Constrói o array de perguntas a partir de \params[:questions].
    #
    # Retorna:
    # - Array de hashes contendo os dados de cada pergunta
    def build_questions_array # :doc:
      Array(params[:questions]).map do |question_data|
        {
          text:    question_data[:text].to_s.strip,
          type:    question_data[:type],
          options: Array(question_data[:options])
        }
      end
    end

    ##
    # Renderiza o formulário com mensagens de erro.
    #
    # Argumentos:
    # - form: instância de TemplateForm com os erros
    # - action_name: símbolo com o nome da ação a ser renderizada (:new ou :edit)
    #
    # Efeitos colaterais:
    # - Define variáveis de instância para reconstruir o formulário
    # - Define mensagem flash de erro
    def render_with_errors(form, action_name) # :doc:
      @name      = form.nome
      @questions = form.questions.map { |dq| map_question_payload(dq) }
      @template ||= Template.new(nome: @name)

      flash.now[:error] = "Erro(s) no template: " +
                          form.errors.map(&:message).join("; ") + "."

      render action_name, layout: "templates", status: :unprocessable_entity
    end

    ##
    # Mapeia os dados de uma pergunta do form para o formato esperado na view.
    #
    # Argumentos:
    # - question_data: hash contendo os dados da pergunta
    #
    # Retorna:
    # - Hash formatado com :pergunta, :tipo e :opcoes
    def map_question_payload(question_data) # :doc:
      {
        pergunta: question_data[:text],
        tipo:     question_data[:type].to_i,
        opcoes:   Array(question_data[:options]).map { |opt| { opcao: opt } }
      }
    end

    ##
    # Retorna as perguntas associadas ao template para edição.
    #
    # Argumentos:
    # - template: instância de Template
    #
    # Retorna:
    # - Array de hashes contendo as perguntas e opções formatadas
    def questions_for_edit(template) # :doc:
      template
        .ligacao_pergunta
        .perguntas
        .includes(:opcoes)
        .order(:id)
        .map { |record| map_edit_question(record) }
    end

    ##
    # Formata os dados de uma pergunta do banco para edição.
    #
    # Argumentos:
    # - record: instância de Pergunta
    #
    # Retorna:
    # - Hash contendo a pergunta, tipo e opções formatadas
    def map_edit_question(record) # :doc:
      {
        pergunta: record.pergunta,
        tipo:     record.tipo.to_s,
        opcoes:   record.opcoes.order(:item).map { |op| { opcao: op.opcao } }
      }
    end
  end
=======
class Admin::TemplatesController < ApplicationController
  layout 'templates_fill', only: [:new, :edit,:index]
  def index
    @valid_templates = Template
                         .joins(ligacao_pergunta: :perguntas)
                         .distinct
                         .includes(ligacao_pergunta: :perguntas)

    @invalid_templates = Template.all - @valid_templates

    # puts "Templates válidos: #{@valid_templates.count}"
    # puts "Templates no banco: #{Template.count}"


    @show_incompatibility_message = Template.count != @valid_templates.count
  end

  def new
    @template = Template.new
  end

  def create
    if params[:questions].blank? || params[:questions].reject { |q| q[:text].blank? }.empty?
      flash.now[:error] = "O template precisa ter pelo menos uma pergunta."
      return render :new
    end

    ActiveRecord::Base.transaction do

      ligacao = LigacaoPergunta.create!

      @template = Template.create!(
        nome: params[:template][:nome],
        ligacao_pergunta: ligacao
      )

      puts "PARAM QUESTIONS: #{params[:questions].inspect}"
      Array(params[:questions]).each do |q|
        pergunta = Pergunta.create!(
          ligacao_pergunta: ligacao,
          tipo:             q[:type].to_i,
          pergunta:         q[:text]
        )

        # Só se for de múltipla escolha
        if q[:type].to_i.zero? && q[:options].present?
          q[:options].reject(&:blank?).each_with_index do |opt, idx|
            Opcao.create!(
              pergunta: pergunta,
              item:     idx + 1,
              opcao:    opt
            )
          end
        end
      end

      redirect_to admin_templates_path,
                  notice: "Template Criado Com Sucesso"
    end

  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = e.record.errors.full_messages.join(", ")
    return render :new
  end

  def edit
    @template  = Template.find(params[:id])
    @ligacao   = @template.ligacao_pergunta
    @questions = @template.ligacao_pergunta.perguntas.includes(:opcoes)
  end

  def update
    @template = Template.find(params[:id])

    if params[:questions].blank? || params[:questions].reject { |q| q[:text].blank? }.empty?
      flash.now[:error] = "O template precisa ter pelo menos uma pergunta."
      return render :edit
    end

    ActiveRecord::Base.transaction do
      ligacao = @template.ligacao_pergunta
      ligacao.perguntas.destroy_all

      @template.update!(nome: params[:template][:nome])

      Array(params[:questions]).each do |q|
        pergunta = Pergunta.create!(
          ligacao_pergunta: ligacao,
          tipo:             q[:type].to_i,
          pergunta:         q[:text]
        )
        if q[:type].to_i.zero? && q[:options].present?
          q[:options].each_with_index do |opt, idx|
            Opcao.create!(pergunta: pergunta, item: idx + 1, opcao: opt)
          end
        end
      end

      redirect_to admin_templates_path, notice: "Template atualizado com sucesso"
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = e.record.errors.full_messages.join(", ")
    render :edit
  end

  def destroy
    @template = Template.find(params[:id])
    @template.destroy!
    redirect_to admin_templates_path, notice: "Template excluído com sucesso"
  end

  private

  def template_params
    params.require(:template).permit(:nome)
  end
>>>>>>> 3059227 (Adicionando documentação)
end