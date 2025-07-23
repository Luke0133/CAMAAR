#language: pt
Funcionalidade: Cadastrar usuários do sistema
  Eu como Administrador
  Quero cadastrar participantes de turmas do SIGAA ao importar dados de usuarios novos para o sistema
  A fim de que eles acessem o sistema CAMAAR

  Contexto:
    Dado que eu estou logado como admin
    E que eu estou na página de gerenciamento do CAMAAR

  Cenário: Upload de dados dos usuários bem-sucedido (HAPPY)
    Quando eu selecionar o arquivo "valido.json" 
    E eu clicar no botão "Importar dados"
    Então eu devo estar na página de gerenciamento do CAMAAR
    E um email deve ter sido enviado para "aluno@email.com"
    E eu devo ver "Dados importados com sucesso"

  Cenário: Tentativa de upload de arquivo de tipo inválido (SAD)
    Quando eu selecionar o arquivo "invalido.txt" 
    E eu clicar no botão "Importar dados"
    Então eu devo estar na página de gerenciamento do CAMAAR
    E eu devo ver "Falha ao importar dados: arquivo com extensão incorreta"

  Cenário: Tentativa de upload de arquivo com informações inválidas (SAD)
    Quando eu selecionar o arquivo "invalido.json"
    E eu clicar no botão "Importar dados" 
    Então eu devo estar na página de gerenciamento do CAMAAR
    E eu devo ver "Falha ao importar dados: dados do arquivo em formato inválido"