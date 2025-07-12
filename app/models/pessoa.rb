class Pessoa < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :recoverable, :rememberable
  devise :database_authenticatable, :registerable

  def self.find_for_database_authentication(warden_conditions)
    Rails.logger.info "ABACAXI OLHA O DATABASE AUTH"
    conditions = warden_conditions.dup
    email = conditions.delete(:email).to_s.downcase
    where("lower(email) = :value OR lower(matricula) = :value", value: email).first
  end
end
