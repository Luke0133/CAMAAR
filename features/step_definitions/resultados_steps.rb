Dado('que eu estou logado como admin') do
end

Dado('que eu estou na página de resultados do CAMAAR') do
  visit admin_resultados_path
end

Dado(/^que existem (\d+) formulários respondidos$/) do |count|
  materia = Materia.create!(id: "MAT1", nome: "Matemática")
  turma1 = Turma.create!(semestre: "2024.1", numero_turma: 1, professor: "Prof. Silva", id_materia: materia.id)
  ligacao = LigacaoPergunta.create!

  count.to_i.times do |i|
    formulario = Formulario.create!(nome: "Formulario #{i + 1}", turma_id: turma1.id, ligacao_pergunta_id: ligacao.id)
    pergunta = Pergunta.create!(ligacao_pergunta_id: ligacao.id, tipo: 1, pergunta: "Pergunta")
    Resposta.create!(formulario_id: formulario.id, pergunta_id: pergunta.id, conteudo: "Resposta")
  end
end

Dado(/^que existem? (\d+) formulários? não respondidos?$/) do |count|
  materia = Materia.create!(id: "MAT1", nome: "Matemática")
  turma = Turma.create!(semestre: "2024.1", numero_turma: 2, professor: "Prof. Souza", id_materia: materia.id)
  ligacao = LigacaoPergunta.create!
  count.to_i.times do |i|
    Formulario.create!(nome: "Não Respondido #{i+1}", turma: turma, ligacao_pergunta: ligacao)
  end
end

Dado(/^que existem? (\d+) formulários? inválidos?$/) do |count|
  materia = Materia.create!(id: "MAT1", nome: "Matemática")
  turma = Turma.create!(semestre: "2024.1", numero_turma: 3, professor: "Prof. Invalido", id_materia: materia.id)
  ligacao = LigacaoPergunta.create!
  count.to_i.times do
    Formulario.create!(nome: nil, turma: turma, ligacao_pergunta: ligacao)
  end
end

Então(/^eu devo ver (\d+) formulários?$/) do |count|
  expect(page).to have_css('.formulario-card', count: count)
end

Então(/^eu devo ver "(.*)"$/) do |text|
  expect(page).to have_content(text)
end