Dado('que eu estou logado como admin') do
end

Dado('que eu estou na página de resultados do CAMAAR') do
  visit admin_resultados_path
end

Dado(/^que existem? (\d+) formulários? respondidos?$/) do |count|
  materia = Materia.create!(id: "#{SecureRandom.uuid}", nome: "Matéria")
  turma = Turma.create!(semestre: "2025.1", numero_turma: rand(100..999), professor: "Prof. Nome", id_materia: materia.id)
  ligacao = LigacaoPergunta.create!

  count.to_i.times do |i|
    formulario = Formulario.create!(nome: "Formulario Respondido #{i + 1} - #{SecureRandom.hex(3)}", turma: turma, ligacao_pergunta: ligacao)
    pergunta = Pergunta.create!(ligacao_pergunta: ligacao, tipo: 1, pergunta: "Pergunta #{i + 1}")
    Resposta.create!(formulario: formulario, pergunta: pergunta, conteudo: "Resposta #{i + 1}")
  end
end

Dado(/^que existem? (\d+) formulários?(?: não respondidos?)?$/) do |count|
  materia = Materia.create!(id: "#{SecureRandom.uuid}", nome: "Matéria")
  turma = Turma.create!(semestre: "2025.1", numero_turma: rand(1000..1999), professor: "Prof. Nome", id_materia: materia.id)
  ligacao = LigacaoPergunta.create!

  count.to_i.times do |i|
    Formulario.create!(nome: "Formulario Não Respondido #{i + 1} - #{SecureRandom.hex(3)}", turma: turma, ligacao_pergunta: ligacao)
  end
end

Dado(/^que existem? (\d+) formulários? inválidos?$/) do |count|
  materia = Materia.create!(id: "#{SecureRandom.uuid}", nome: "Matéria")
  turma = Turma.create!(semestre: "2025.1", numero_turma: rand(2000..2999), professor: "Prof. Nome", id_materia: materia.id)
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