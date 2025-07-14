# já definidos em importar_dados_steps.rb
Dado('que eu estou logado como admin') do
  @admin = FactoryBot.create(:pessoa, :admin, email: 'admin@example.com', password: 'password')
  visit new_pessoa_session_path
  fill_in 'Email', with: @admin.email
  fill_in 'Senha', with: 'password'
  click_button 'Entrar'
end

Dado('que eu estou na página de gerenciamento do CAMAAR') do
  visit admin_gerenciamento_path
  expect(page).to have_content(/Gerenciamento/i)
end

Quando('eu clicar no botão "Importar dados"') do 
  click_button 'Importar dados'
end

Quando('eu selecionar o arquivo {string}') do 
  caminho = Rails.root.join('spec', 'fixtures', nome_arquivo)
  attach_file('arquivo', caminho)
end

Então('eu devo estar na página de gerenciamento do CAMAAR') do
  expect(current_path).to eq admin_gerenciamento_path
end

Então('eu devo ver {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Dado('que foram importados dados do SIGAA') do
  caminho = Rails.root.join("spec/fixtures/valido.json")
  json = JSON.parse(File.read(caminho))
  ImportadorSigaa.new(json).processar
end

Então('um email deve ter sido enviado para {string}') do |email|
  mail = ActionMailer::Base.deliveries.find { |m| m.to.include?(email) }
  expect(mail).not_to be_nil
  expect(mail.subject).to match(/Redefinir senha/i)
end


Quando('eu selecionar o arquivo {string} para importar') do |nome_arquivo|
  caminho = Rails.root.join("spec/fixtures/#{nome_arquivo}")
  attach_file('file', caminho, visible: false)
  click_button 'Importar dados'
end
