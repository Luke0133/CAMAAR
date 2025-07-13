require 'rails_helper'

RSpec.feature "Criação de Formulário", type: :feature do
  let!(:admin) do
    Pessoa.where(email: "admin@exemplo.com").destroy_all
    Pessoa.create!(
      email: "admin@exemplo.com",
      nome: "Admin",
      matricula: "123456789",
      senha: "123456"
    )
  end

  let!(:template) do
    ligacao = LigacaoPergunta.create!
    Pergunta.create!(pergunta: "Pergunta exemplo", tipo: 1, ligacao_pergunta_id: ligacao.id)
    Template.create!(nome: "template_teste", ligacao_pergunta_id: ligacao.id)
  end

  let!(:materia) do
    Materia.create!(id: "MAT01", nome: "materia_teste")
  end

  def login_as_admin
    # Login desabilitado para foco exclusivo no formulário
  end

  scenario "Criação de um formulário de avaliação bem-sucedida" do
    login_as_admin
    visit new_formulario_path

    expect(page).to have_current_path(new_formulario_path)

    select "template_teste", from: "Template"
    select "materia_teste", from: "Matéria"
    click_button "Enviar"

    expect(page).to have_current_path(formularios_path)
    expect(page).to have_content("Formulário enviado com sucesso")
  end

  scenario "Tentativa de criar um formulário sem selecionar um template" do
    login_as_admin
    visit new_formulario_path

    select "materia_teste", from: "Matéria"
    click_button "Enviar"

    expect(page).to have_content("Nenhum template selecionado")
  end

  scenario "Tentativa de criar um formulário sem selecionar uma matéria" do
    login_as_admin
    visit new_formulario_path

    select "template_teste", from: "Template"
    click_button "Enviar"

    expect(page).to have_content("Nenhuma matéria foi selecionada")
  end
end
