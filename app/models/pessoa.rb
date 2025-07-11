class Pessoa < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = warden_conditions[:email]&.downcase
    if login
      where("lower(email) = :value OR lower(matricula) = :value", value: login).first
    else
      nil
    end
  end
end
