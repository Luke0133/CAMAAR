require 'rails_helper'

RSpec.describe ImportadorSigaa, type: :service do
  let(:json_data) do
    [
      {
        "id" => 1,
        "code" => "CIC0001",
        "classCode" => "1",
        "name" => materia_nome,
        "time" => "24T23",
        "semester" => semestre,
        "discente" => [
          {
            "nome" => aluno_nome,
            "matricula" => "123456789",
            "usuario" => "aluno@email.com",
            "formacao" => "Graduação",
            "ocupacao" => "Estudante",
            "email" => "aluno@email.com"
          }
        ],
        "docente" => {
          "nome" => professor_nome,
          "usuario" => "prof@email.com",
          "formacao" => "Doutorado",
          "ocupacao" => "Docente",
          "email" => "prof@email.com",
          "departamento" => "CIC"
        }
      }
    ]
  end

  let(:materia_nome)     { "OAC" }
  let(:semestre)         { "2025.1" }
  let(:professor_nome)   { "Prof. Teste" }
  let(:aluno_nome)       { "Aluno Teste" }

  before do
    ActionMailer::Base.deliveries.clear
    Devise.mappings[:pessoa] ||= Devise::Mapping.new(:pessoa, {})
  end

  describe '#processar' do
    subject(:importar) { ImportadorSigaa.new(json_data).processar }

    context 'quando todos os dados são novos' do
      it 'cria registros e envia e-mail' do
        expect { importar }
          .to change(Materia, :count).by(1)
          .and change(Turma, :count).by(1)
          .and change(Pessoa, :count).by(2)
          .and change(Cargo, :count).by(2)
          .and change(Participante, :count).by(1)

        expect(Materia.find("CIC0001").nome).to eq("OAC")
        expect(Pessoa.find_by(email: "prof@email.com").nome).to eq("Prof. Teste")
        expect(Pessoa.find_by(email: "aluno@email.com").nome).to eq("Aluno Teste")
        expect(Turma.find(1).semestre).to eq("2025.1")

        aluno = Pessoa.find_by(email: "aluno@email.com")
        expect(aluno.reset_password_token).not_to be_nil

        mail = ActionMailer::Base.deliveries.find { |m| m.to.include?("aluno@email.com") }
        expect(mail).not_to be_nil
        expect(mail.subject).to match(/Definição de Senha/i)
      end
    end

    context 'quando registros já existem' do
      let(:materia_nome) { "ISC" }

      before do
        Materia.create!(id: "CIC0001", nome: "OAC")
        Pessoa.create!(nome: "Prof", email: "prof@email.com", matricula: "987654321", senha: "testeProfessor")
        Pessoa.create!(nome: "Aluno", email: "aluno@email.com", matricula: "123456789", senha: "testeAluno")
        Turma.create!(id: 1, id_materia: "CIC0001", numero_turma: 1, semestre: "2024.2", professor: "Prof")
      end

      it 'atualiza os dados existentes corretamente' do
        expect { importar }.not_to change(Materia, :count)

        expect(Materia.find("CIC0001").nome).to eq("ISC")
        expect(Pessoa.find_by(email: "prof@email.com").nome).to eq("Prof. Teste")
        expect(Pessoa.find_by(email: "aluno@email.com").nome).to eq("Aluno Teste")
        expect(Turma.find(1).semestre).to eq("2025.1")
      end
    end
  end
end
