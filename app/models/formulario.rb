class Formulario < ApplicationRecord
  belongs_to :turma
  belongs_to :ligacao_pergunta
  has_many :respostas

  scope :respondidos, -> { joins(:respostas).distinct }
  scope :invalidos, -> { where(nome: nil) } # TODO: considerar situações adicionais em que um formulário seria inválido

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