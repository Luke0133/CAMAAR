##
# Controladora responsável pela criação de formulários
#
# Usa o layout personalizado "criar_formulario".
#
# Funcionalidades principais:
# - Criar formulários para docentes e/ou discentes
#
class Admin::FormulariosController < Admin::BaseAdminController
  layout "criar_formulario"
  
  ##
  # Constante para mapear informação recebida no form de criação de formulários
  # ao inteiro correspondente do campo +:destino+ da classe Formulario
  #
  # Possíveis destinos:
  # - "aluno" => 1,
  # - "professor" => 2
  # - "todos" => 3 (tanto aluno, quanto professor)
  #
  DESTINO_MAP = {
    "aluno" => 1,
    "professor" => 2,
    "todos" => 3
  }.freeze

  ##
  # Exibe a página de criação de formulário.
  # que ainda não foram respondidos
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Carrega os dados necessários (templates, matérias e turmas)
  # - Inicializa a variável de instância @formulario
  #
  def new
    carregar_dados_formulario
    @formulario = Formulario.new
  end

  ##
  # Cria formulários com base no template selecionado e nas matérias escolhidas.
  #
  # Redireciona para a página de gerenciamento com aviso de sucesso
  # ou renderiza o formulário novamente com mensagem de erro
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  # 
  # Efeitos colaterais:
  # - Salva novos registros no banco de dados (Formularios).
  # - Caso haja sucesso, redireciona para a página de gerenciamento,
  #   lançando um +flash[:notice]+ de sucesso. 
  # - Caso haja erro, renderiza novamente +:new+ com um +flash[:alert]+ de erro
  #
  def create
    carregar_dados_formulario

    return render_erro(:template, "Nenhum template selecionado") if params.dig(:formulario, :template_id).blank?
    return render_erro(:materia, "Nenhuma matéria foi selecionada") if params.dig(:formulario, :materia_ids).blank?

    template = Template.find(formulario_params[:template_id])
    created_forms = criar_formularios_para_materias(template)

    if created_forms.any?
      flash[:notice] = "Formulário enviado com sucesso"
      redirect_to admin_gerenciamento_path
    else
      mensagem = flash.now[:alert] || "Erro ao salvar os formulários"
      render_erro(:formulario, mensagem)
    end
  end

  private

  ##
  # Carrega os dados necessários para a criação do formulário
  # (templates, matérias e suas respectivas turmas)
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  # 
  # Efeitos colaterais:
  # - Inicializa a variável de instância @templates
  # - Atribui informações todas as matérias à variável de instância @materias
  # - Atribui informações quanto à quantidade de turmas por matéria à variável de instância @turmas_por_materia
  #
  def carregar_dados_formulario #:doc:
    @templates = Template.all
    @materias = Materia.includes(:turmas).all
    @turmas_por_materia = @materias.index_with { |materia| materia.turmas.first }
  end

  ##
  # Verifica se o parâmetro de template está em branco.
  #
  # Não recebe argumentos.
  #
  # Retorno:
  # [Boolean] true, se os parâmetros estiverem em branco, false caso contrário
  #
  # Não possui efeitos colaterais
  def template_id_blank?#:doc:
    formulario_params[:template_id].blank?
  end

  ##
  # Verifica se os IDs das matérias estão em branco.
  #
  # Não recebe argumentos.
  #
  # Retorno:
  # [Boolean] true, caso os ids das matérias estiverem em branco
  #
  # Não possui efeitos colaterais
  def materia_ids_blank?#:doc:
    formulario_params[:materia_ids].blank?
  end

  ##
  # Renderiza a tela de novo formulário com mensagens de erro e os dados necessários.
  # 
  # Argumentos:
  # [Symbol] tipo: tipo de erro (:template ou :materia)
  # [String] mensagem: mensagem de erro a ser exibida
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Renderiza a view +:new+ com os dados e mensagem de erro.
  # - Inicializa a variável de instância @formulario (caso ainda não tenha sido definida).
  # - Carrega todos os templates e os atribui à variável de instância @templates.
  # - Carrega todas as matérias e as atribui à variável de instância @materias.
  # - Carrega todas as turmas por matéria e as atribui à variável de instância @turmas_por_materia.
  # - Define uma variável de instância dinâmica (ex: @template_error ou @materia_error) com a mensagem de erro.
  # - Define a mensagem de ero a ser exibida +flash.now[:alert]+.
  def render_erro(tipo, mensagem)#:doc:
    @formulario = Formulario.new if @formulario.nil?
    @templates = Template.all
    @materias = Materia.all
    @turmas_por_materia = Turma.includes(:materia).index_by(&:materia)
    instance_variable_set("@#{tipo}_error", mensagem)
    flash.now[:alert] = mensagem
    render :new
  end


  ##
  # Cria formulários para cada matéria selecionada com base em um template.
  #
  # Argumentos:
  # [Template] template: o template usado como base para os formulários
  # [Array<Formulario>] return: lista de formulários criados com sucesso
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Salva novos registros de Formulario no banco.
  # - Pode interromper o processo caso alguma matéria não possua turma.
  #

  def criar_formularios_para_materias(template)#:doc:
    formulario_params[:materia_ids].filter_map do |materia_id|
      criar_formulario_para_materia(template, materia_id)
    end
  end

##
# Cria um formulário para uma única matéria com base em um template.
#
# Acessa o banco para buscar a matéria e sua turma
#
# Argumentos:
# [Template] template: template usado como base para o formulário
# [String] materia_id: ID da matéria para a qual será criado o formulário
#
# Retorna: 
# [Formulario, nil] o formulário criado, ou nil se a matéria não tiver turma
#
# Efeitos colaterais:
# - Exibe alerta caso a matéria não tenha turma.
# - Salva o formulário no banco de dados.
#

  def criar_formulario_para_materia(template, materia_id)#:doc:
    materia = Materia.find(materia_id)
    turma = materia.turmas.first

    return sem_turma_alerta(materia) unless turma

    formulario = construir_formulario(template, turma)
    formulario.save ? formulario : nil
  end

##
# Exibe alerta informando que a matéria não possui turma.
#
# Argumentos:
# [Materia] materia: matéria sem turma
# 
# Retorna: 
# [nil]
#
# Efeitos colaterais:
# - Define um flash de alerta com a mensagem de erro.
#

  def sem_turma_alerta(materia)#:doc:
    flash.now[:alert] = "A matéria #{materia.nome} não possui turmas"
    nil
  end

##
# Constrói um novo objeto Formulario a partir do template e da turma,
# verificando o destino do formulário
#
# Argumentos:
# [Template] template: template usado como base
# [Turma] turma: turma associada ao formulário
#
# Retorna: 
# [Formulario] instância do formulário (não salva)
#
# Não possuui efeitos colaterais
  def construir_formulario(template, turma)#:doc:
    destino_param = formulario_params[:destino]
    destino_int = DESTINO_MAP[destino_param] || 3

    Formulario.new(
      ligacao_pergunta_id: template.ligacao_pergunta_id,
      turma_id: turma.id,
      nome: template.nome,
      destino: destino_int
    )
  end
##
# Define os parâmetros permitidos para criação de formulários.
#
# Não possui argumentos
#
# Retorna: 
# [ActionController::Parameters] Objeto contendo apenas os parâmetros permitidos.
#
# Não possuui efeitos colaterais
  def formulario_params#:doc:
    params.require(:formulario).permit(:template_id, :destino, materia_ids: [])
  end
end