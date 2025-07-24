##
# Modelo que representa a participação de uma pessoa em uma turma
#
# Associações:
# - Pertence a uma pessoa
# - Pertence a uma turma
#
class Participante < ApplicationRecord
  belongs_to :pessoa, foreign_key: 'email'
  belongs_to :turma, foreign_key: 'id_turma'
end
