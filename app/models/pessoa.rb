class Pessoa < ApplicationRecord
  validates :email, presence: true
end