class RespostaCsvPresenter
  def initialize(resposta)
    @resposta = resposta
    @pergunta = resposta.pergunta
  end

  def to_csv_row
    [
      @pergunta&.pergunta,
      @pergunta&.tipo,
      @resposta.conteudo
    ]
  end
end