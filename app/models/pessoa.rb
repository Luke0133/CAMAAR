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

  has_many :cargos, foreign_key: 'email', dependent: :destroy
  has_many :participantes, foreign_key: 'email', dependent: :destroy
  has_many :turmas, through: :participantes
  has_many :formulario_respondidos, foreign_key: 'email', dependent: :destroy

  # 💡 Core Logic
  def formularios_nao_respondidos
    Formulario
      .where(turma_id: turmas.select(:id)) # Forms for my turmas
      .where.not(id: formularios_ja_respondidos.select(:id)) # Not answered yet
      .includes(:ligacao_pergunta)
      .select(&:valido?) # Only valid
  end
end
