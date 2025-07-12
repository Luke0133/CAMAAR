# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Limpa os dados antigos (opcional em ambiente de desenvolvimento)
FormularioRespondido.delete_all
Formulario.delete_all
Participante.delete_all
Pessoa.delete_all
Turma.delete_all
Materia.delete_all
LigacaoPergunta.delete_all

# Cria pessoa
aluno = Pessoa.create!(
  email: "aluno@teste.com",
  nome: "Aluno Teste",
  matricula: "123456",
  senha: "123456"
)

# Cria matéria
materia = Materia.create!(
  id: "MAT123",
  nome: "Matemática"
)

# Cria turmas
turma1 = Turma.create!(
  semestre: "2024.1",
  numero_turma: 1,
  professor: "Prof. João",
  id_materia: materia.id
)

turma2 = Turma.create!(
  semestre: "2024.1",
  numero_turma: 2,
  professor: "Prof. Maria",
  id_materia: materia.id
)

# Associa aluno às turmas
Participante.create!(email: aluno.email, id_turma: turma1.id)
Participante.create!(email: aluno.email, id_turma: turma2.id)

# Cria ligação de perguntas (dummy)
lig = LigacaoPergunta.create!

# Cria formulários
form1 = Formulario.create!(
  nome: "Formulario 1",
  ligacao_pergunta: lig,
  turma: turma1
)

form2 = Formulario.create!(
  nome: "Formulário 2",
  ligacao_pergunta: lig,
  turma: turma1
)


form3 = Formulario.create!(
  nome: "Formulário 3",
  ligacao_pergunta: lig,
  turma: turma1
)


form4 = Formulario.create!(
  nome: "Formulário 4",
  ligacao_pergunta: lig,
  turma: turma1
)


form5 = Formulario.create!(
  nome: "Formulário 5",
  ligacao_pergunta: lig,
  turma: turma1
)

form6 = Formulario.create!(
  nome: "Formulário 6",
  ligacao_pergunta: lig,
  turma: turma1
)
form7 = Formulario.create!(
  nome: "Formulário 7",
  ligacao_pergunta: lig,
  turma: turma1
)
form8 = Formulario.create!(
  nome: "Formulário 8",
  ligacao_pergunta: lig,
  turma: turma1
)
form9 = Formulario.create!(
  nome: "Formulário 9",
  ligacao_pergunta: lig,
  turma: turma1
)
formd10 = Formulario.create!(
  nome: "Formulário 10",
  ligacao_pergunta: lig,
  turma: turma1
)
fordm11 = Formulario.create!(
  nome: "",
  ligacao_pergunta: lig,
  turma: turma1
)

fordm12 = Formulario.create!(
  nome: "a",
  ligacao_pergunta: lig,
  turma: turma1
)

fordm14 = Formulario.create!(
  nome: "b",
  ligacao_pergunta: lig,
  turma: turma1
)

fqorm13 = Formulario.create!(
  nome: "c",
  ligacao_pergunta: lig,
  turma: turma1
)

formq16 = Formulario.create!(
  nome: "d",
  ligacao_pergunta: lig,
  turma: turma1
)

forqm15 = Formulario.create!(
  nome: "e",
  ligacao_pergunta: lig,
  turma: turma1
)

forqm12 = Formulario.create!(
  nome: "f",
  ligacao_pergunta: lig,
  turma: turma1
)

form14 = Formulario.create!(
  nome: "g",
  ligacao_pergunta: lig,
  turma: turma1
)

formq13 = Formulario.create!(
  nome: "h",
  ligacao_pergunta: lig,
  turma: turma1
)

formq16 = Formulario.create!(
  nome: "i",
  ligacao_pergunta: lig,
  turma: turma1
)

formq15 = Formulario.create!(
  nome: "j",
  ligacao_pergunta: lig,
  turma: turma1
)


formq1e5 = Formulario.create!(
  nome: "jf",
  ligacao_pergunta: lig,
  turma: turma1
)
# Marca form1 como respondido
FormularioRespondido.create!(
  email: aluno.email,
  formulario: form1
)

puts "Seeding complete"