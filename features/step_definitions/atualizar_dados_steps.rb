# já definidos em importar_dados_steps.rb
#Dado('que eu estou logado como admin') do

#Dado('que eu estou na página de gerenciamento do CAMAAR') do

#Quando('eu clicar no botão "Importar dados"') do |_botao|

#Quando('eu selecionar o arquivo {string}') do |nome_arquivo|

#Então('eu devo estar na página de gerenciamento do CAMAAR') do

#Então('eu devo ver {string}') do |mensagem|

Dado('que foram importados dados do SIGAA') do
  caminho = Rails.root.join("spec/fixtures/valido.json")
  json = JSON.parse(File.read(caminho))
  ImportadorSigaa.new(json).processar
end
