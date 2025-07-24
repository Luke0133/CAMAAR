##
# Serviço responsável por processar os dados de um JSON para atualizar ou criar
# os registros correspondentes no banco de dados.
#
# Utilizado pela controller da página de gerenciamento para processar os dados
# recebidos pelo botão "Importar dados".
#
class ImportadorSigaa
  ##
  # Inicializa o importador com os dados JSON.
  #
  # Argumentos:
  # - json_data: Array de hashes representando as turmas e seus dados.
  #
  def initialize(json_data)
    @json_data = json_data.map { |turma| TurmaInfo.new(turma) }
  end

  ##
  # Utiliza o método importar de cada classe de Importador para processar os dados do JSON,
  # processando as matérias, professores, turmas e alunos correspondentes.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Criação ou atualização de registros no banco de dados.
  #
  def processar
    @json_data.each do |turma_info|
      ImportadorMateria.new(turma_info).importar
      ImportadorProfessor.new(turma_info).importar
      ImportadorTurma.new(turma_info).importar
      ImportadorAlunos.new(turma_info).importar
    end
  end
end

##
# Classe auxiliar para encapsular os dados de cada turma e facilitar o acesso aos seus dados.
#
# Utilizada pelos importadores para acessar os atributos de forma dinâmica.
#
class TurmaInfo

  ##
  # Inicializa a instância com os dados fornecidos.
  #
  # Argumentos:
  # - data: [Hash] Hash com os dados da turma.
  #
  def initialize(data)
    @data = data
  end

  ##
  # Permite acessar os dados da turma como se fossem atributos, mesmo que não sejam
  # definidos explicitamente como métodos.
  #
  # Tenta buscar o atributo no hash original por nome, tanto como string quanto como símbolo.
  #
  # Argumentos:
  # - name: [Symbol] Nome do atributo a ser acessado.
  # - args: [Array] Argumentos adicionais (não utilizados, mas presentes para compatibilidade).
  #
  # Retorna:
  # - [Object, nil] Valor do atributo se existir, ou nil caso contrário.
  #
  def method_missing(name, *args)
    @data[name.to_s] || @data[name.to_sym]
  end

  ##
  # Verifica se o método chamado existe no hash de dados.
  #
  # Argumentos:
  # - name: [Symbol] Nome do método a ser verificado.
  # - include_private: [Boolean] Indica se deve incluir métodos privados na verificação (não utilizado, mas presente para compatibilidade).
  #
  # Retorna:
  # - [Boolean] true se o método existir no hash de dados, false caso contrário.
  #
  def respond_to_missing?(name, include_private = false)
    @data.key?(name.to_s) || @data.key?(name.to_sym) || super
  end
end

##
# Classe auxiliar para armazenar os dados de cada importador.
#
# Utilizada para definir a inicialização dos importadores, como também o método de definir 
# dados de pessoas, comum entre os importadores de professores e alunos.
#
class ImportadorBase
  attr_reader :turma_info

  ##
  # Inicializa o importador com os dados da turma.
  #
  # Argumentos:
  # - turma_info: instância de +TurmaInfo+ com os dados da turma.
  # 
  def initialize(turma_info)
    @turma_info = turma_info
  end

  ##
  # Define os dados de uma pessoa com base nas informações fornecidas.
  #
  # Argumentos:
  # - pessoa: instância de +Pessoa+ a ser criada ou atualizada.
  # - info: [Hash] Hash com os dados da pessoa.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Define ou atualiza um objeto +Pessoa+ no banco de dados.
  #
  def set_dados_pessoa(pessoa, info)
    pessoa.update!(
      nome: info["nome"],
      matricula: info["matricula"],
      senha: pessoa.senha || nil
    )
  end

  ##
  # Verifica se o e-mail já existe no banco de dados, ou cria um novo registro se não existir.
  #
  # Argumentos:
  # - email: [String] E-mail a ser verificado.
  #
  # Retorna:
  # - [Pessoa, Boolean, String] Retorna a instância de +Pessoa+, um booleano indicando se é novo
  #   e o e-mail em si.
  #
  # Efeitos colaterais:
  # - Criação de um novo registro de +Pessoa+ se o e-mail não existir.
  #
  def check_email(email)
    email = email.downcase.strip
    pessoa = Pessoa.find_by(email: email)
    novo = false

    if pessoa.nil?
      pessoa = Pessoa.new(email: email)
      novo = true
    end
    [pessoa, novo, email]
  end

  ##
  # Envia um e-mail inicial para uma pessoa para a definição de senha.
  #
  # Argumentos:
  # - pessoa: instância de +Pessoa+.
  # - email: [String] E-mail da pessoa para envio do link de definição de senha.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Envia um e-mail com o link de definição de senha.
  # - Registra o envio no log de emails_enviados.
  #
  def enviar_email_inicial(pessoa, email)
    time = Time.current

    raw_token, enc_token = Devise.token_generator.generate(Pessoa, :reset_password_token)
    pessoa.update!(reset_password_token: enc_token, reset_password_sent_at: time)
    Devise::Mailer.reset_password_instructions(pessoa, raw_token).deliver_now

    url = Rails.application.routes.url_helpers.edit_pessoa_password_url(
      reset_password_token: raw_token,
      host: "localhost:3000"
    )

    File.open(Rails.root.join("log", "emails_enviados.log"), "a") do |arquivo_log|
      arquivo_log.puts "[#{time}] Enviado para #{email} - Token: #{raw_token} - URL: #{url}"
    end
  end
end

##
# Importadores específicos para cada tipo de dado,
# verificando se já existem registros e atualizando-os ou criando novos conforme necessário.
# 

##
# Importador específico para as matérias.
#
class ImportadorMateria < ImportadorBase
  ##
  # Importa ou atualiza a matéria com base nas informações fornecidas.
  #
  # Verifica se a matéria já existe pelo código e atualiza o nome se necessário,
  # ou cria uma nova matéria caso não exista.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Criação ou atualização de registros de matérias no banco de dados.
  # - Criação ou atualização de registros de pessoa e cargo no banco de dados (professor).
  #
  def importar
    code = turma_info.code
    name = turma_info.name
    materia = Materia.find_by(id: code)

    if materia
      materia.update!(nome: name) if materia.nome != name
    else
      Materia.create!(id: code, nome: name)
    end
  end
end

##
# Importador específico para os professores.
#
class ImportadorProfessor < ImportadorBase
  ##
  # Importa ou atualiza o professor com base nas informações fornecidas.
  #
  # Verifica se o professor já existe pelo e-mail e atualiza os dados se necessário,
  # ou cria um novo registro e envia um e-mail para o usuário caso não exista.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Criação ou atualização de registros de pessoa e cargo no banco de dados.
  #
  def importar
    docente = turma_info.docente

    pessoa, novo, email = check_email(docente["email"])

    set_dados_pessoa(pessoa, docente)

    Cargo.find_or_create_by!(email: pessoa.email, funcao: 2)

    # Todo professor importado será um admin
    Cargo.find_or_create_by!(email: pessoa.email, funcao: 0)

    enviar_email_inicial(pessoa, email) if novo
  end
end

##
# Importador específico para as turmas.
#
class ImportadorTurma < ImportadorBase
  ##
  # Importa ou atualiza a turma com base nas informações fornecidas.
  #
  # Verifica se a turma já existe pelo ID e atualiza os dados se necessário,
  # ou cria um novo registro caso não exista.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Criação ou atualização de registros de turma no banco de dados.
  # - Criação ou atualização de registros de participação (no caso do docente) no banco de dados.
  #
  def importar
    Turma.find_or_create_by(id: turma_info.id).tap do |turma|
      turma.update!(
        id_materia: turma_info.code,
        numero_turma: turma_info.classCode.to_i,
        semestre: turma_info.semester,
        professor: turma_info.docente["nome"]
      )
      turma_info.instance_variable_get(:@data)["id"] ||= turma.id
    end

    docente_email = turma_info.docente["email"]
    Participante.find_or_create_by!(email: docente_email, id_turma: turma_info.id)
  end
end

##
# Importador específico para os alunos.
#
class ImportadorAlunos < ImportadorBase
  ##
  # Importa ou atualiza os alunos com base nas informações de turma definidas na inicialização do objeto.
  #
  # Verifica se o aluno já existe pelo e-mail e atualiza os dados se necessário,
  # ou cria um novo registro caso não exista, enviando um e-mail de definição de senha neste caso.
  #
  # Não recebe argumentos.
  #
  # Não há retorno.
  #
  # Efeitos colaterais:
  # - Criação ou atualização de registros de pessoa, cargo e participante no banco de dados.
  #
  def importar
    turma_info.discente.each do |aluno|
      pessoa, novo, email = check_email(aluno["email"])

      set_dados_pessoa(pessoa, aluno)

      Cargo.find_or_create_by!(email: email) { |cargo| cargo.funcao = 1 }

      Participante.find_or_create_by!(email: email, id_turma: turma_info.id)

      enviar_email_inicial(pessoa, email) if novo
    end
  end
end