require 'rails_helper'

RSpec.describe ImportadorSIGAA, type: :service do
  describe '#processar' do
    let(:json_data) do
      [
        {
          "code" => "CIC0001",
          "classCode" => "1",
          "name" => "OAC",
          "time" => "24T23",
          "semester" => "2025.1",
          "dicente" => [
            {
              "nome" => "José",
              "matricula" => "123456789",
              "usuario" => "jose@email.com",
              "formacao" => "Graduação",
              "ocupacao" => "Estudante",
              "email" => "jose@email.com"
            }
          ],
          "docente" => {
            "nome" => "Prof. Lamar",
            "usuario" => "lamar@email.com",
            "formacao" => "Doutorado",
            "ocupacao" => "Docente",
            "email" => "lamar@email.com",
            "departamento" => "CIC"
          }
        }
      ]
    end

    it 'importa todos os dados corretamente' do
      expect {
        ImportadorSIGAA.new(json_data).processar
      }.to change(Materia, :count).by(1)
       .and change(Turma, :count).by(1)
       .and change(Pessoa, :count).by(2)
       .and change(Cargo, :count).by(2)
       .and change(Participantes, :count).by(1)
    end
  end
end
