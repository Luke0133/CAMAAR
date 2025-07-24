##
# Modelo que representa uma pergunta
#
# Associações:
# - Pertence a uma ligação de pergunta
# - Possui muitas respostas
# - Possui muitas opções (caso o seu tipo seja de múltipla escolha)
#
# Possíveis tipos:
# - 0: Múltipla escolha
# - 1: Texto
#
class Pergunta < ApplicationRecord
  belongs_to :ligacao_pergunta
  has_many :opcoes, foreign_key: 'pergunta_id', dependent: :destroy
  has_many :respostas, dependent: :destroy
end
