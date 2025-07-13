class Formulario < ApplicationRecord
  belongs_to :turma
  belongs_to :ligacao_pergunta
  has_many :respostas

  # TODO: considerar situações adicionais em que um formulário seria inválido
  scope :validos, -> { where.not(nome: nil) }
  scope :invalidos, -> { where(nome: nil) }

  def generate_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[Pergunta Tipo Resposta]
      respostas.includes(:pergunta).each do |resposta|
        csv << [
          resposta.pergunta&.pergunta,
          resposta.pergunta.tipo,
          resposta.conteudo
        ]
      end
    end
  end
end