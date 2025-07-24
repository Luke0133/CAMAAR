##
# Modelo que representa uma pessoa
#
# Associações:
# - Possui muitas cargos (pode ter mais de um)
# - Possui muitos registros de formulários respondidos
# - Possui muitos registros de participação de turmas (muitas turmas por meio de Participantes)
#
#
class Pessoa < ApplicationRecord
  
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, authentication_keys: [:login]

  attr_writer :login

  ##
  # Recupera o valor de login utilizado na autenticação
  #
  # Usado para permitir que o usuário faça o login com matrícula ao invés de forçar usar o email
  #
  # Retorno:
  # - [String] login do usuário (prioriza `@login`, depois `email`, depois `matricula`)
  #
  # Não possui efeitos colaterais
  def login
    @login || email || matricula
  end

  ##
  # Realiza a autenticação personalizada via Devise.
  #
  # Este método sobrescreve a autenticação padrão para aceitar tanto email quanto matrícula como credencial de login.
  #
  # Argumento:
  # [Hash] warden_conditions: Condições de login fornecidas pelo Devise/Warden (contendo a chave `:login`)
  #
  # Retorno:
  # [Pessoa, nil] Retorna a instância da Pessoa se encontrada, ou `nil` caso contrário.
  #
  def self.find_for_database_authentication(warden_conditions)
    login = warden_conditions[:login].to_s.downcase
    where("lower(email) = :value OR lower(matricula) = :value", value: login).first
  end

  has_many :cargos, foreign_key: 'email', dependent: :destroy
  has_many :participantes, foreign_key: 'email', dependent: :destroy
  has_many :turmas, through: :participantes
  has_many :formulario_respondidos, foreign_key: 'email', dependent: :destroy
end
