class Formulario < ApplicationRecord
  belongs_to :ligacao_pergunta
  belongs_to :turma

  has_many :respostas, dependent: :destroy
  has_many :formulario_respondidos, dependent: :destroy


  scope :respondidos, -> { joins(:respostas).distinct }
  scope :invalidos, -> { where(nome: "") }

  scope :validos, -> { where.not(id: invalidos.select(:id)) }
end