#language: pt
Funcionalidade: Sistema de Login
  Eu como Usuário do sistema
  Quero acessar o sistema utilizando um e-mail ou matrícula e uma senha já cadastrada
  A fim de responder formulários ou gerenciar o sistema
  Obs: Quando o Usuário logado for um admin, deve-se mostrar a opção de gerenciamente no menu lateral.

  Contexto:
    Dado que eu estou na página de login do CAMAAR
    Dado que existe uma pessoa cadastrada com "email@registrado" e "senhaCorreta"

  Cenário: Login realizado com sucesso (HAPPY)
    Quando eu preencher o campo "Email ou Matrícula" com "email@registrado"
    E eu preencher o campo "Senha" com "senhaCorreta"
    E eu clicar no botão "Entrar"
    Então eu devo estar na página de avaliação do CAMAAR

  Cenário: Login com e-mail não cadastrados (SAD)
    Quando eu preencher o campo "Email ou Matrícula" com "email@nãoRegistrado"
    E eu preencher o campo "Senha" com "senhaCorreta"
    E eu clicar no botão "Entrar"
    Então eu devo ver "Login ou senha inválidos"

  Cenário: Login com senha incorreta (SAD)
    Quando eu preencher o campo "Email ou Matrícula" com "email@Registrado"
    E eu preencher o campo "Senha" com "senhaIncorreta"
    E eu clicar no botão "Entrar"
    Então eu devo ver "Login ou senha inválidos"