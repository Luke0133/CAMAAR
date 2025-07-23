# Esse serviço é responsável por processar os dados importados do SIGAA vindos 
# do botão "Importar dados" da tela de gerenciamento.
# Ele lê um JSON contendo informações sobre turmas, professores e alunos,
# e atualiza ou cria os registros correspondentes no banco de dados.
class ImportadorSigaa
  def initialize(json_data)
    @json_data = json_data.map { |turma| TurmaInfo.new(turma) }
    @atualizado = false
  end

  def processar
    @json_data.each do |turma_info|
      ImportadorMateria.new(turma_info).importar
      ImportadorProfessor.new(turma_info).importar
      turma = ImportadorTurma.new(turma_info).importar
      ImportadorAlunos.new(turma_info, turma).importar
    end
    @atualizado
  end
end

# Classe auxiliar para encapsular os dados de cada turma
# e facilitar o acesso aos seus dados.
class TurmaInfo
  def initialize(data)
    @data = data
  end

  def method_missing(name, *args)
    @data[name.to_s] || @data[name.to_sym]
  end

  def respond_to_missing?(name, include_private = false)
    @data.key?(name.to_s) || @data.key?(name.to_sym) || super
  end
end

# Classe auxiliar para armazenar os dados de cada importador.
class ImportadorBase
  attr_reader :turma_info

  def initialize(turma_info)
    @turma_info = turma_info
  end

  def set_dados_pessoa(pessoa, info)
    pessoa.update!(
      nome: info["nome"],
      matricula: info["matricula"],
      senha: pessoa.senha || nil
    )
  end
end

# Importadores específicos para cada tipo de dado,
# verificando se já existem registros e atualizando-os ou criando novos conforme necessário.

# Importador específico para as matérias.
class ImportadorMateria < ImportadorBase
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

# Importador específico para os professores.
class ImportadorProfessor < ImportadorBase
  def importar
    docente = turma_info.docente
    pessoa = Pessoa.find_or_create_by(email: docente["email"])
    set_dados_pessoa(pessoa, docente)

    Cargo.find_or_create_by!(email: pessoa.email) do |cargo|
      cargo.funcao = 1
    end
  end
end

# Importador específico para as turmas.
class ImportadorTurma < ImportadorBase
  def importar
    Turma.find_or_create_by(id: turma_info.id).tap do |turma|
      turma.update!(
        id_materia: turma_info.code,
        numero_turma: turma_info.classCode.to_i,
        semestre: turma_info.semester,
        professor: turma_info.docente["nome"]
      )
    end
  end
end

# Importador específico para os alunos.
class ImportadorAlunos < ImportadorBase
  def initialize(turma_info, turma)
    super(turma_info)
    @turma = turma
  end

  def importar
    turma_info.discente.each do |aluno|
      email = aluno["email"]

      pessoa = Pessoa.find_by(email: email)
      novo = false

      if pessoa.nil?
        pessoa = Pessoa.new(email: email)
        novo = true
      end

      set_dados_pessoa(pessoa, aluno)

      Cargo.find_or_create_by!(email: email) { |cargo| cargo.funcao = 2 }

      Participante.find_or_create_by!(email: email, id_turma: @turma.id)

      enviar_email_inicial(pessoa, email) if novo
    end
  end

  private

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