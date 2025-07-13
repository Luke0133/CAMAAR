class Pessoa < ApplicationRecord
  # Associations
  self.primary_key = "email"
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