class Admin::TemplatesController < ApplicationController
  layout 'templates_fill', only: [:new, :edit, :index]
  def index
    @valid_templates = Template
                         .joins(ligacao_pergunta: :perguntas)
                         .distinct
                         .includes(ligacao_pergunta: :perguntas)
    @invalid_templates = Template.all - @valid_templates
    @show_incompatibility_message = Template.count != @valid_templates.count
  end

  def new
    @template = Template.new
  end

  def create
    @template = Template.new(template_params)
    @name = params[:template][:nome]

    @questions = (params[:questions] || []).map do |q|
      {
        pergunta: q[:text] || q["text"],
        tipo: (q[:type] || q["type"]).to_i,
        opcoes: Array(q[:options] || q["options"]).map { |opt| { opcao: opt } }
      }
    end

    if @name.blank?
      flash.now[:error] = "O nome do template não pode estar em branco."
      return render :new, layout: 'templates_fill', status: :unprocessable_entity
    end

    if @questions.blank? || @questions.any? { |q| q[:pergunta].blank? }
      flash.now[:error] = "O template precisa ter pelo menos uma pergunta e todas as perguntas devem ter texto."
      return render :new, layout: 'templates_fill', status: :unprocessable_entity
    end

    @questions.each_with_index do |q, index|
      if q[:tipo] == 0
        original_options = (params[:questions][index][:options] || params[:questions][index]["options"]) || []
        if original_options.any?(&:blank?)
          flash.now[:error] = "Todas as opções das perguntas de múltipla escolha devem estar preenchidas."
          return render :new, layout: 'templates_fill', status: :unprocessable_entity
        end
      end
    end

    ActiveRecord::Base.transaction do

      ligacao = LigacaoPergunta.create!

      @template = Template.create!(
        nome: params[:template][:nome],
        ligacao_pergunta: ligacao
      )

      Array(params[:questions]).each do |q|
        pergunta = Pergunta.create!(
          ligacao_pergunta: ligacao,
          tipo:             q[:type].to_i,
          pergunta:         q[:text]
        )

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
    @name = params[:template][:nome]
    @questions = (params[:questions] || []).map do |q|
      {
        pergunta: q[:text] || q["text"],
        tipo: (q[:type] || q["type"]).to_i,
        opcoes: Array(q[:options] || q["options"]).map { |opt| { opcao: opt } }
      }
    end
    return render :new, layout: 'templates_fill', status: :unprocessable_entity
  end

  def edit
    @template = Template.find_by(id: params[:id])

    unless @template
      redirect_to admin_templates_path, alert: "Falha ao editar: o template selecionado não existe."
      return
    end

    @ligacao   = @template.ligacao_pergunta
    @questions = @template.ligacao_pergunta.perguntas.includes(:opcoes)
  end

  def update
    @template = Template.find_by(id: params[:id])

    unless @template
      redirect_to admin_templates_path, alert: "Falha ao editar: o template selecionado não existe."
      return
    end

    @name = params[:template][:nome]

    @questions = (params[:questions] || []).map do |q|
      {
        pergunta: q[:text] || q["text"],
        tipo: (q[:type] || q["type"]).to_i,
        opcoes: Array(q[:options] || q["options"]).map { |opt| { opcao: opt } }
      }
    end

    if @name.blank?
      flash.now[:error] = "O nome do template não pode estar em branco."
      return render :edit, layout: 'templates_fill', status: :unprocessable_entity
    end

    if @questions.blank? || @questions.any? { |q| q[:pergunta].blank? }
      flash.now[:error] = "O template precisa ter pelo menos uma pergunta e todas as perguntas devem ter texto."
      return render :edit, layout: 'templates_fill', status: :unprocessable_entity
    end

    @questions.each_with_index do |q, index|
      if q[:tipo] == 0
        original_options = (params[:questions][index][:options] || params[:questions][index]["options"]) || []
        if original_options.any?(&:blank?)
          flash.now[:error] = "Todas as opções das perguntas de múltipla escolha devem estar preenchidas."
          return render :edit, layout: 'templates_fill', status: :unprocessable_entity
        end
      end
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
    @name = params[:template][:nome]
    @questions = (params[:questions] || []).map do |q|
      {
        pergunta: q[:text] || q["text"],
        tipo: (q[:type] || q["type"]).to_i,
        opcoes: Array(q[:options] || q["options"]).map { |opt| { opcao: opt } }
      }
    end
    return render :edit, layout: 'templates_fill', status: :unprocessable_entity
  end

  def destroy
    @template = Template.find_by(id: params[:id])

    if @template
      nome = @template.nome
      @template.destroy!
      redirect_to admin_templates_path, notice: "O #{nome} foi excluído!"
    else
      redirect_to admin_templates_path, alert: "Falha ao excluir: o template selecionado não existe."
    end
  end

  private

  def template_params
    params.require(:template).permit(:nome)
  end
end