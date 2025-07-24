##
# Modelo que representa a ligação entre um formulário ou template com as perguntas
#
# Associações:
# - Possui muitas perguntas
# - Possui muitos formulários
# - Possui muitos templates
#
class LigacaoPergunta < ApplicationRecord
  has_many :templates, dependent: :destroy
  has_many :perguntas, dependent: :destroy
  has_many :formularios, dependent: :destroy
end
