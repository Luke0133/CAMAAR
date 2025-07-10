# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# Clean-up: Remove dependent records before parents

# Remove respostas tied to perguntas for MAT1-linked data
Resposta.joins(:pergunta)
        .where(perguntas: { ligacao_pergunta_id: LigacaoPergunta.select(:id) })
        .delete_all

# Remove perguntas
Pergunta.where(ligacao_pergunta_id: LigacaoPergunta.select(:id)).delete_all

# Remove formularios tied to turmas 1 and 2
Formulario.where(turma_id: Turma.where(numero_turma: [1, 2], semestre: "2024.1").select(:id)).delete_all

# Remove ligacoes
LigacaoPergunta.delete_all

# Remove turmas tied to MAT1
Turma.where(numero_turma: [1, 2], semestre: "2024.1", id_materia: "MAT1").delete_all

# Finally, remove the materia
Materia.where(id: "MAT1").delete_all

# Re-seed

materia = Materia.create!(id: "MAT1", nome: "Matemática")

turma1 = Turma.create!(semestre: "2024.1", numero_turma: 1, professor: "Prof. Silva", id_materia: materia.id)
turma2 = Turma.create!(semestre: "2024.1", numero_turma: 2, professor: "Prof. Souza", id_materia: materia.id)

ligacao = LigacaoPergunta.create!

nomes = ["Qualidade do conteúdo", "Didática", "Avaliações e trabalhos"]
nomes.each do |nome|
  pergunta = Pergunta.create!(ligacao_pergunta_id: ligacao.id, tipo: 1, pergunta: "Pergunta")
  formulario = Formulario.create!(nome: nome, turma_id: turma1.id, ligacao_pergunta_id: ligacao.id)
  Resposta.create!(formulario_id: formulario.id, pergunta_id: pergunta.id, conteudo: "Resposta")
end


2.times do |i|
  Formulario.create!(nome: "Aluno Não Respondido #{i+1}", turma_id: turma2.id, ligacao_pergunta_id: ligacao.id)
end

Formulario.create!(nome: nil, turma_id: turma1.id, ligacao_pergunta_id: ligacao.id)