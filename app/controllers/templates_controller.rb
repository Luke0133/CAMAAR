class TemplatesController < ApplicationController
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
end

