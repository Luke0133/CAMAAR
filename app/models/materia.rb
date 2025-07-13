class Materia < ApplicationRecord
  has_many :turmas, foreign_key: 'id_materia', primary_key: 'id'
end
