##
# Modelo que representa um template de formulário contendo perguntas associadas.
#
# Associações:
# - Pertence a uma ligação de pergunta (LigacaoPergunta)
# - Possui muitas perguntas através da ligação de pergunta
#
# Aceita atributos aninhados para:
# - Perguntas (permite criar/editar perguntas junto com o template)
#
# Callbacks:
# - Após destruir: remove a LigacaoPergunta se ela estiver órfã
#
# Observações:
# - Este modelo serve como estrutura base para criação de formulários
# - A exclusão de um template pode acarretar a exclusão da LigacaoPergunta se não houver mais vínculos
#
# Exemplo de uso:
#   template = Template.create(nome: "Modelo de Avaliação", perguntas_attributes: [...])
#   template.destroy # Remove a LigacaoPergunta associada se não houver mais vínculos
#
class Template < ApplicationRecord
  belongs_to :ligacao_pergunta
  has_many :perguntas, through: :ligacao_pergunta
  accepts_nested_attributes_for :perguntas

  after_destroy :cleanup_ligacao_if_orphaned

  private

  ##
  # Remove a LigacaoPergunta se não estiver associada a nenhum template ou formulário.
  #
  # Efeitos colaterais:
  # - Pode excluir a LigacaoPergunta do banco de dados.
  #
  def cleanup_ligacao_if_orphaned
    return unless ligacao_pergunta.templates.empty? && ligacao_pergunta.formularios.empty?

    ligacao_pergunta.destroy!
  end
end