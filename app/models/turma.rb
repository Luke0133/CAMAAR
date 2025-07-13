class Turma < ApplicationRecord
  belongs_to :materia, foreign_key: :id_materia, optional: true
end