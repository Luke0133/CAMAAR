# Dado('que eu estou logado como admin') do

# Dado('que eu estou na página de gerenciamento do CAMAAR') do

# Quando('eu clicar no botão "Importar dados"') do

# Quando('eu selecionar o arquivo {string}') do |nome_arquivo|

# Então('eu devo ver {string}') do |mensagem|

# Então('eu devo estar na página de gerenciamento do CAMAAR') do

Então('um email deve ter sido enviado para {string}') do |email|
  mail = ActionMailer::Base.deliveries.find { |m| m.to.include?(email) }
  expect(mail).not_to be_nil
  expect(mail.subject).to match(/Redefinir senha/i)
end
