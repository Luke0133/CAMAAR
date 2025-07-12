class ImportadorSigaa
  def initialize(json_data)
    @json_data = json_data
  end

  def processar
    @json_data.each do |turma_info|
      importar_materia(turma_info)
      importar_professor(turma_info)
      turma = importar_turma(turma_info)
      importar_alunos(turma_info, turma)
    end
  end

  private

  def importar_materia(info)
    Materia.find_or_create_by!(
      id: info["code"]
    ) do |m|
      m.nome = info["name"]
    end
  end

  def importar_professor(info)
    docente = info["docente"]
    pessoa = Pessoa.find_or_create_by!(email: docente["email"]) do |p|
      p.nome = docente["nome"]
      p.matricula = docente["usuario"]
      p.senha = "testeProfessor"
    end

    Cargo.find_or_create_by!(email: pessoa.email) do |c|
      c.funcao = 1 # 1 = professor
    end
  end

  def importar_turma(info)
    Turma.find_or_create_by!(
      id_materia: info["code"],
      numero_turma: info["classCode"],
      semestre: info["semester"]
    ) do |t|
      t.professor = info["docente"]["usuario"]
    end
  end

  def importar_alunos(info, turma)
    info["dicente"].each do |aluno|
      pessoa = Pessoa.find_or_create_by!(email: aluno["usuario"]) do |p|
        p.nome = aluno["nome"]
        p.matricula = aluno["matricula"]
        p.senha = "testeAluno"
      end

      Cargo.find_or_create_by!(email: pessoa.email) do |c|
        c.funcao = 2 # 2 = aluno
      end

      Participante.find_or_create_by!(
        email: pessoa.email,
        id_turma: turma.id
      )
    end
  end
end