class FormularioCsvExporter
  def initialize(formulario)
    @formulario = formulario
  end

  def generate
    CSV.generate(headers: true) do |csv|
      csv << %w[Pergunta Tipo Resposta]

      @formulario.respostas.includes(:pergunta).each do |resposta|
        csv << RespostaCsvPresenter.new(resposta).to_csv_row
      end
    end
  end
end