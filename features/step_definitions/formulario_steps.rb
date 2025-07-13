

Dado("que eu estou na página de envio do CAMAAR") do
  visit new_formulario_path
end

Dado("que existe um template chamado {string}") do |nome_template|
  ligacao = LigacaoPergunta.create!
  Pergunta.create!(pergunta: "Pergunta de exemplo", tipo: 1, ligacao_pergunta_id: ligacao.id)
  Template.create!(nome: nome_template, ligacao_pergunta_id: ligacao.id)
end

Dado("que existe uma matéria chamada {string}") do |nome_materia|
  materia = Materia.create!(id: "MAT01", nome: nome_materia)
  Turma.create!(semestre: "2025.1", numero_turma: 1, professor: "Prof. X", id_materia: materia.id)
end

Quando(/^eu escolher o template "(.*)"$/) do |nome_template|
  select nome_template, from: "Template"
end

Quando(/^eu selecionar a matéria "(.*)"$/) do |nome_materia|
  select nome_materia, from: "Matéria"
end

Quando("eu clicar no botão “Enviar”") do
  click_button "Enviar"
end

Então("eu devo estar na página de gerenciamento do CAMAAR") do
  expect(page).to have_current_path(new_formulario_path)
end


Então(/^eu devo ver a mensagem "(.*)"$/) do |mensagem|
  expect(page).to have_content(mensagem)
end
