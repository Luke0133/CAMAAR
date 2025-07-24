##
# Modelo que representa uma resposta a uma pergunta de um formulário.
#
# Associações:
# - Pertence a um formulário
# - Pertence a uma pergunta
#
class Resposta < ApplicationRecord
  belongs_to :formulario
  belongs_to :pergunta
end
