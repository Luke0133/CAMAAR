#language: pt
Funcionalidade: Sistema de definição de senha
  Eu como Usuário
  Quero definir uma senha para o meu usuário a partir do e-mail do sistema de solicitação de cadastro
  A fim de acessar o sistema

  Cenário: Senha definida com sucesso (HAPPY)
    Dado que eu estou na página de registro do CAMAAR com um token válido
    Quando eu preencher o campo "Nova Senha" com "mypassword"
    E eu preencher o campo "Confirme a Senha" com "mypassword"
    E eu clicar no botão "Definir Senha"
    Então eu devo estar na página de avaliação do CAMAAR
    E deve existir uma pessoa cadastrada com "myemail@email" e "mypassword"

  Cenário: Falha na definição de senha (SAD)
    Dado que eu estou na página de registro do CAMAAR com um token inválido
    Quando eu preencher o campo "Nova Senha" com "mypassword"
    E eu preencher o campo "Confirme a Senha" com "mypassword"
    E eu clicar no botão "Definir Senha"
    Então eu devo ver "Token de redefinição de senha é inválido"