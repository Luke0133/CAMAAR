##
# Presenter responsável por formatar uma resposta para inclusão em linha CSV.
#
# Utilizado pelo exportador de formulários para compor as linhas do arquivo.
#
class RespostaCsvPresenter
  ##
  # Inicializa o presenter com uma instância de Resposta.
  #
  # Argumentos:
  # - resposta: instância de +Resposta+ associada à pergunta.
  #
  def initialize(resposta)
    @resposta = resposta
    @pergunta = resposta.pergunta
  end

  ##
  # Converte os dados da resposta em um array que representa uma linha CSV.
  #
  # Retorna:
  # - Array com os valores: [pergunta, tipo da pergunta, conteúdo da resposta].
  #
  # Efeitos colaterais:
  # - Nenhum.
  #
  # Exemplo de uso:
  #   RespostaCsvPresenter.new(resposta).to_csv_row
  def to_csv_row
    [
      @pergunta&.pergunta,
      @pergunta&.tipo,
      @resposta.conteudo
    ]
  end
end