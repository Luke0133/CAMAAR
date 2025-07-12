class LigacaoPergunta < ApplicationRecord
  has_many :templates
  has_many :perguntas  # se isso fizer sentido no seu modelo
end
