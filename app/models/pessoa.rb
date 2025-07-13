class Pessoa < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable
end