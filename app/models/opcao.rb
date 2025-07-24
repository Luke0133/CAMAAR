##
# Modelo que representa uma opção de pergunta
#
# Associações:
# - Pertence a uma pergunta (uma pergunta de multipla escolha, que pode ter várias opções)
#
class Opcao < ApplicationRecord
    belongs_to :pergunta, foreign_key: 'pergunta_id'
end
