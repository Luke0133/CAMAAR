##
# Modelo que representa uma turma
#
# Associações:
# - Pertence a uma matéria (toda turma deve ter uma matéria)
# - Possui muitos participantes
# - Possui muitas pessoas (por meio de Participantes)
# - Possui muitos formulários (para que os seus participantes possam responder)
#
class Turma < ApplicationRecord
  
  belongs_to :materia, foreign_key: 'id_materia', primary_key: 'id', optional: true
  
  has_many :participantes, foreign_key: 'id_turma', dependent: :destroy
  has_many :pessoas, through: :participantes
  has_many :formularios, dependent: :destroy
end
