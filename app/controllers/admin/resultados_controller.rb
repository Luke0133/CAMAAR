##
# Controladora responsável pela gestão de resultados dos formulários no painel administrativo.
#
# Usa o layout personalizado "resultados".
#
# Funcionalidades principais:
#
# - Listar formulários válidos
# - Exibir aviso caso existam formulários inválidos
# - Verificar existência de respostas antes de permitir downloads
# - Gerar e enviar arquivos CSV com os resultados dos formulários
#
class Admin::ResultadosController < Admin::BaseAdminController
  layout "resultados"

  ##
  # Exibe a lista de formulários válidos.
  #
  # Caso existam formulários inválidos, exibe uma mensagem de erro informando
  # que não podem ser visualizados.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Atribui formulários válidos à variável de instância @forms
  # - Exibe uma mensagem +flash[:warning]+ caso existam formulários inválidos
  #
  # Exemplo de uso:
  #   GET /admin/resultados
  def index
    @forms = Formulario.validos

    if Formulario.invalidos.any?
      flash[:warning] = "Um ou mais formulários estão incompatíveis e não podem ser visualizados."
    end
  end

  # Filtro que executa antes das ações :download e :preparar_download
  before_action :verificar_respostas_existentes, only: [:download, :preparar_download]

  ##
  # Verifica se o formulário possui respostas antes de permitir ações de download.
  #
  # Não recebe argumentos (recebe a identificação do formulário via \params[:id])
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Se o formulário não tiver respostas:
  #   - Redireciona para a listagem de resultados
  #   - Define uma mensagem flash de aviso
  #
  # Usado como filtro para as ações download e preparar_download.
  def verificar_respostas_existentes
    @formulario = Formulario.find(params[:id])
    if @formulario.respostas.empty?
      flash[:error] = "Este formulário ainda não contém respostas"
      redirect_to admin_resultados_path
    end
  end

  ##
  # Prepara o ambiente para o download do arquivo de resultados.
  #
  # Não recebe argumentos (usa @formulario do filtro[ResultadosController.html#method-i-verificar_respostas_existentes]).
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Define mensagens flash:
  #   - \flash[:success] com confirmação do download
  #   - \flash[:download_form_id] com o ID do formulário
  # - Redireciona para a listagem de resultados
  #
  # Exemplo de uso:
  #   GET /admin/resultados/:id/preparar_download
  def preparar_download
    flash[:success] = "Arquivo de resultado baixado com sucesso"
    flash[:download_form_id] = @formulario.id
    redirect_to admin_resultados_path
  end

  ##
  # Realiza o envio de um arquivo CSV contendo os resultados do formulário.
  #
  # O nome do arquivo gerado inclui:
  # - Nome do formulário
  # - Nome da matéria
  # - Semestre
  # - Número da turma
  #
  # Não recebe argumentos (recebe a identificação do formulário via \params[:id] - atribuído em filtro).
  #
  # Retorna: arquivo CSV enviado ao navegador.
  #
  # Efeitos colaterais:
  # - Envia dados via `send_data` como download de arquivo
  #
  # Exemplo de uso:
  #   GET /admin/resultados/:id/download
  def download
    csv_data = @formulario.generate_csv
    turma = @formulario.turma
    materia = turma&.materia

    filename = "respostas_#{@formulario.nome}_#{materia&.nome}_#{turma&.semestre}_turma-#{turma&.numero_turma}.csv"

    send_data csv_data, filename: filename, type: "text/csv"
  end
end