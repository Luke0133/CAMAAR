class Opcao < ApplicationRecord
  self.primary_keys = :pergunta_id, :item

  belongs_to :pergunta, foreign_key: 'pergunta_id'
end
