
Dado('que existem {int} templates') do |quantidade|
  quantidade.times do |i|
    ligacao = LigacaoPergunta.create!

    Pergunta.create!(pergunta: "Pergunta #{i+1}", ligacao_pergunta_id: ligacao.id, tipo: 1)
    Template.create!(ligacao_pergunta_id: ligacao.id, nome: "Template #{i+1}")

  end
end

Dado('que existem {int} templates inválido') do |quantidade|
  quantidade.times do |i|
    ligacao = LigacaoPergunta.create!

    Template.create!(ligacao_pergunta_id: ligacao.id, nome: "Template inválido #{i + 1}")
  end
end


Quando('eu clicar no botão {string}') do |botao|
  click_on botao
end

Então('eu devo estar na página de gerenciamento de templates do CAMAAR') do
  expect(page).to have_current_path(templates_path)
end

Então('eu devo ver {int} templates') do |quantidade|
  expect(page).to have_selector('.template-card', count: quantidade)
end
Então('nenhum template deve ser exibido na lista') do
  expect(page).not_to have_selector('.template-card')
end
Então('eu devo ver {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
