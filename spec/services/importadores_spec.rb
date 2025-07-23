require 'rails_helper'

RSpec.describe ImportadorBase do
  let(:pessoa) { Pessoa.create!(email: "teste@email.com", senha: "senha123") }
  let(:info) { { "nome" => "Novo Nome", "matricula" => "987654321" } }

  it 'atualiza os dados da pessoa corretamente' do
    described_class.new(nil).set_dados_pessoa(pessoa, info)
    pessoa.reload

    expect(pessoa.nome).to eq("Novo Nome")
    expect(pessoa.matricula).to eq("987654321")
  end
end


RSpec.describe ImportadorMateria do
  let(:turma_info) { TurmaInfo.new({ "code" => "CIC0001", "name" => "ISC" }) }

  context 'quando a matéria não existe' do
    it 'cria uma nova matéria' do
      expect {
        described_class.new(turma_info).importar
      }.to change(Materia, :count).by(1)

      expect(Materia.find("CIC0001").nome).to eq("ISC")
    end
  end

  context 'quando a matéria já existe com nome diferente' do
    before { Materia.create!(id: "CIC0001", nome: "OAC") }

    it 'atualiza o nome da matéria' do
      described_class.new(turma_info).importar
      expect(Materia.find("CIC0001").nome).to eq("ISC")
    end
  end
end

RSpec.describe ImportadorProfessor do
  let(:docente) do
    {
      "nome" => "Prof Teste",
      "matricula" => "987654321",
      "email" => "prof@email.com"
    }
  end

  let(:turma_info) { TurmaInfo.new({ "docente" => docente }) }

  it 'cria ou atualiza o professor e o cargo' do
    expect {
      described_class.new(turma_info).importar
    }.to change(Pessoa, :count).by(1)
     .and change(Cargo, :count).by(1)

    pessoa = Pessoa.find_by(email: docente["email"])
    expect(pessoa.nome).to eq("Prof Teste")
    expect(pessoa.matricula).to eq("987654321")
    expect(Cargo.find_by(email: pessoa.email).funcao).to eq(1)
  end
end

RSpec.describe ImportadorTurma do
  let(:turma_info) do
    TurmaInfo.new(
      {
        "id" => 1,
        "code" => "CIC0001",
        "classCode" => "1",
        "semester" => "2025.1",
        "docente" => { "nome" => "Prof Teste" },
      }
    )
  end

  before do
    Materia.create!(id: "CIC0001")
  end

  it 'cria ou atualiza a turma' do
    described_class.new(turma_info).importar

    turma = Turma.find(1)
    expect(turma.id_materia).to eq("CIC0001")
    expect(turma.numero_turma).to eq(1)
    expect(turma.semestre).to eq("2025.1")
    expect(turma.professor).to eq("Prof Teste")
  end
end

RSpec.describe ImportadorAlunos do
  let(:turma) { Turma.create!(id: 1, id_materia: "CIC0001", numero_turma: 1, semestre: "2025.1", professor: "Prof Teste") }

  let(:aluno_info) do
    {
      "nome" => "Aluno Teste",
      "matricula" => "123456789",
      "email" => "aluno@email.com"
    }
  end

  let(:turma_info) { TurmaInfo.new({ "discente" => [aluno_info] }) }

  before do
    Materia.create!(id: "CIC0001")
    ActionMailer::Base.deliveries.clear
    Devise.mappings[:pessoa] ||= Devise::Mapping.new(:pessoa, {})
  end

  it 'cria novo aluno, cargo, participante e envia e-mail' do
    expect {
      described_class.new(turma_info, turma).importar
    }.to change(Pessoa, :count).by(1)
     .and change(Cargo, :count).by(1)
     .and change(Participante, :count).by(1)

    aluno = Pessoa.find_by(email: "aluno@email.com")
    expect(aluno.nome).to eq("Aluno Teste")
    expect(aluno.reset_password_token).not_to be_nil

    mail = ActionMailer::Base.deliveries.find { |m| m.to.include?("aluno@email.com") }
    expect(mail).not_to be_nil
  end
end

RSpec.describe TurmaInfo do
  # Checa se responds_to e method missing estão funcionando
  let(:data) do
    {
      "name" => "OAC",
      :code => "CIC0001",
      "docente" => {
        "nome" => "Prof",
        "email" => "prof@email.com"
      }
    }
  end

  subject(:turma_info) { described_class.new(data) }

  describe '#respond_to?' do
    it 'responde a métodos baseados nas chaves da hash (string)' do
      expect(turma_info.respond_to?(:name)).to be true
    end

    it 'responde a métodos baseados nas chaves da hash (symbol)' do
      expect(turma_info.respond_to?(:code)).to be true
    end

    it 'não responde a métodos não existentes' do
      expect(turma_info.respond_to?(:banana)).to be false
    end
  end

  describe '#method_missing' do
    it 'acessa corretamente valores de string keys' do
      expect(turma_info.name).to eq("OAC")
    end

    it 'acessa corretamente valores de symbol keys' do
      expect(turma_info.code).to eq("CIC0001")
    end

    it 'acessa corretamente hashes aninhadas' do
      expect(turma_info.docente["nome"]).to eq("Prof")
    end
  end
end