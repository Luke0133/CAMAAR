##
# Modelo que representa um cargo de uma pessoa
#
# Associações:
# - Pertence a uma pessoa (uma pessoa pode ter mais de um cargo)
#
# Possíveis funções:
# - 0: admin
# - 1: aluno
# - 2: professor
#
class Cargo < ApplicationRecord
  belongs_to :pessoa, foreign_key: 'email'
end