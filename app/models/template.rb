##
# Modelo que representa um template de formulário contendo perguntas associadas.
#
# Associações:
# - Pertence a uma ligação de pergunta (LigacaoPergunta)
# - Possui muitas perguntas através da ligação de pergunta
#
# Aceita atributos aninhados para:
# - Perguntas (permite criar/editar perguntas junto com o template)
#
# Observações:
# - Este modelo serve como estrutura base para criação de formulários
# Exemplo de uso:
#   template = Template.create(nome: "Modelo de Avaliação", perguntas_attributes: [...])
#
class Template < ApplicationRecord
  belongs_to :ligacao_pergunta
  has_many :perguntas, through: :ligacao_pergunta
  accepts_nested_attributes_for :perguntas
end