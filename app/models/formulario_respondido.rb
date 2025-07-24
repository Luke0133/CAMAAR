##
# Modelo que representa os formulários respondidos por uma pessoa
#
# Associações:
# - Pertence a uma pessoa
# - Pertence a um formulário
class FormularioRespondido < ApplicationRecord
  belongs_to :pessoa, foreign_key: 'email'
  belongs_to :formulario
end
