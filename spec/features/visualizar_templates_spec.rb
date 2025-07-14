require 'rails_helper'

RSpec.feature "Gerenciamento de Templates", type: :feature do
  let!(:admin) do
    Pessoa.where(email: "admin@exemplo.com").destroy_all
    Pessoa.create!(
      email: "admin@exemplo.com",
      nome: "Admin",
      matricula: "123456789",
      senha: "123456"  
    )
  end

  def login_as_admin
    
  end

  scenario "Visualizar templates válidos" do
    2.times do |i|
      ligacao = LigacaoPergunta.create!
      Pergunta.create!(pergunta: "Pergunta #{i+1}", ligacao_pergunta_id: ligacao.id, tipo: 1)
      Template.create!(ligacao_pergunta_id: ligacao.id, nome: "Template #{i+1}")
    end

    login_as_admin
    visit root_path

    expect(page).to have_selector('.template-card', count: 2)
    expect(page).not_to have_content("Um ou mais templates estão incompatíveis e não podem ser visualizados")
  end

  scenario "Não visualizar templates inválidos e mostrar aviso" do
    2.times do |i|
      ligacao = LigacaoPergunta.create!
      Template.create!(ligacao_pergunta_id: ligacao.id, nome: "Template inválido #{i + 1}")
    end

    login_as_admin
    visit root_path

    expect(page).not_to have_selector('.template-card')
    expect(page).to have_content("Um ou mais templates estão incompatíveis e não podem ser visualizados")
  end

  scenario "Visualizar somente templates válidos e mostrar aviso" do
    ligacao_valida = LigacaoPergunta.create!
    Pergunta.create!(pergunta: "Pergunta", ligacao_pergunta_id: ligacao_valida.id, tipo: 1)
    Template.create!(ligacao_pergunta_id: ligacao_valida.id, nome: "Template válido")

    ligacao_invalida = LigacaoPergunta.create!
    Template.create!(ligacao_pergunta_id: ligacao_invalida.id, nome: "Template inválido")

    login_as_admin
    visit root_path

    expect(page).to have_selector('.template-card', count: 1)
    expect(page).to have_content("Template válido")
    expect(page).not_to have_content("Template inválido")
    expect(page).to have_content("Um ou mais templates estão incompatíveis e não podem ser visualizados")
  end
end

