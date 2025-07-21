require 'rails_helper'

RSpec.describe ImportadorSigaa, type: :service do
  describe '#processar' do
    let!(:materia_existente) do
      Materia.create!(id: "CIC0001", nome: "OAC")
    end

    let!(:professor_existente) do
      Pessoa.create!(nome: "Prof", email: "prof@email.com", matricula: "123", senha: "testeProfessor")
    end

    let!(:aluno_existente) do
      Pessoa.create!(nome: "Aluno", email: "aluno@email.com", matricula: "123456789", senha: "testeAluno")
    end

    let!(:turma_existente) do
      Turma.create!(id: 1, id_materia: "CIC0001", numero_turma: 1, semestre: "2024.2", professor: "prof@email.com")
    end

    let(:json_data) do
      [
        {
          "id" => 1,
          "code" => "CIC0001",
          "classCode" => "1",
          "name" => "ISC",
          "time" => "24T23",
          "semester" => "2025.1",
          "dicente" => [
            {
              "nome" => "Aluno Teste",
              "matricula" => "123456789",
              "usuario" => "aluno@email.com",
              "formacao" => "Graduação",
              "ocupacao" => "Estudante",
              "email" => "aluno@email.com"
            }
          ],
          "docente" => {
            "nome" => "Prof. Teste",
            "usuario" => "987654321",
            "formacao" => "Doutorado",
            "ocupacao" => "Docente",
            "email" => "prof@email.com",
            "departamento" => "CIC"
          }
        }
      ]
    end

    it 'atualiza os dados corretamente quando já existem' do
      expect {
        ImportadorSigaa.new(json_data).processar
      }.not_to change(Materia, :count)

      materia = Materia.find_by(id: "CIC0001")
      expect(materia.nome).to eq("ISC")

      professor = Pessoa.find_by(email: "prof@email.com")
      expect(professor.nome).to eq("Prof. Teste")

      aluno = Pessoa.find_by(email: "aluno@email.com")
      expect(aluno.nome).to eq("Aluno Teste")

      turma = Turma.find(1)
      expect(turma.semestre).to eq("2025.1")
      expect(turma.professor).to eq("prof@email.com")
    end
  end
end
