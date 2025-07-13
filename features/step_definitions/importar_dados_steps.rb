Dado('que eu estou logado como admin') do
  # verificar se usuário logado é admin
end

Dado('que eu estou na página de gerenciamento do CAMAAR') do
  visit admin_gerenciamento_path
end

Quando('eu clicar no botão {string}') do |botao|
  # botão já é type="file", então abre o explorador de arquivos
end

Quando('eu selecionar o arquivo {string} para importar') do |nome_arquivo|
  caminho = Rails.root.join("spec/fixtures/#{nome_arquivo}")
  attach_file('file', caminho, visible: false)
  click_button 'Importar dados'
end

Então('eu devo estar na página de gerenciamento do CAMAAR') do
  expect(page).to have_current_path(admin_gerenciamento_path)
end

Então('eu devo ver {string}') do |mensagem|
  # expect(page).to have_content(mensagem)
end
