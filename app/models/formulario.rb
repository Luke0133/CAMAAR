##
# Modelo que representa um formulário com perguntas e respostas associadas.
#
# Associações:
# - Pertence a uma ligação de pergunta (LigacaoPergunta)
# - Pertence a uma turma (Turma)
# - Possui muitas respostas
# - Possui muitos registros de formulários respondidos
#
# Escopos:
# - +respondidos+: retorna formulários que possuem pelo menos uma resposta
# - +validos+: retorna formulários com nome preenchido
# - +invalidos+: retorna formulários com nome em branco
#
class Formulario < ApplicationRecord

  belongs_to :ligacao_pergunta
  belongs_to :turma

  has_many :respostas, dependent: :destroy
  has_many :formulario_respondidos, dependent: :destroy

  scope :respondidos, -> { joins(:respostas).distinct }
  scope :invalidos, -> { where(nome: "") }
  scope :validos, -> { where.not(id: invalidos.select(:id)) }
  # destino: 1 = aluno, 2 = professor, 3 = ambos
  
  ##
  # Gera o conteúdo CSV das respostas do formulário.
  #
  # Não recebe argumentos.
  #
  # Retorna:
  # - Uma string no formato CSV com os dados de pergunta, tipo e resposta.
  #
  # Efeitos colaterais:
  # - Nenhum efeito colateral.
  #
  # Exemplo de uso:
  #   formulario.generate_csv
  def generate_csv
    FormularioCsvExporter.new(self).generate
  end
end