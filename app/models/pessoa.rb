class Pessoa < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, authentication_keys: [:login]

  attr_writer :login

  def login
    @login || email || matricula
  end

  def self.find_for_database_authentication(warden_conditions)
    login = warden_conditions[:login].to_s.downcase
    where("lower(email) = :value OR lower(matricula) = :value", value: login).first
  end
end
