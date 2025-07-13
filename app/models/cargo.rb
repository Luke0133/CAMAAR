class Cargo < ApplicationRecord
  belongs_to :pessoa, foreign_key: 'email'
end
