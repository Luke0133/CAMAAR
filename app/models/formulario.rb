class Formulario < ApplicationRecord
  belongs_to :turma
  belongs_to :ligacao_pergunta
  has_many :respostas

  scope :respondidos, -> { joins(:respostas).distinct }
  scope :invalidos, -> { where(nome: nil) } # TODO: considerar situações adicionais em que um formulário seria inválido
end