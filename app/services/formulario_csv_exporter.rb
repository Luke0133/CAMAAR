require 'csv'

##
# Classe responsável por gerar o conteúdo CSV de um formulário completo.
#
# Utiliza o +RespostaCsvPresenter+ para formatar cada linha.
#
class FormularioCsvExporter
  ##
  # Inicializa o exportador com uma instância de Formulario.
  #
  # Argumentos:
  # - formulario: instância de +Formulario+ que será exportada.
  #
  def initialize(formulario)
    @formulario = formulario
  end

  ##
  # Gera o conteúdo do CSV para o formulário fornecido.
  #
  # Retorna:
  # - Uma string com o conteúdo no formato CSV.
  #
  # Efeitos colaterais:
  # - Nenhum.
  #
  # Exemplo de uso:
  #   FormularioCsvExporter.new(formulario).generate
  def generate
    CSV.generate(headers: true) do |csv|
      csv << %w[Pergunta Tipo Resposta]

      @formulario.respostas.includes(:pergunta).each do |resposta|
        csv << RespostaCsvPresenter.new(resposta).to_csv_row
      end
    end
  end
end