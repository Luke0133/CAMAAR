class Turma < ApplicationRecord
  belongs_to :materia, foreign_key: 'id_materia', primary_key: 'id'
end