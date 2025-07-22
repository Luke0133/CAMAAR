#language: pt
Funcionalidade: Redefinir senha do usuário
    Eu como Usuário
    Quero redefinir uma senha para o meu usuário a partir do e-mail recebido após a solicitação da troca de senha
    A fim de recuperar o meu acesso ao sistema

  Cenário: Admin redefinindo senha a partir da página de gerenciamento (HAPPY)
    Dado que eu estou logado como admin
    E que eu estou na página de gerenciamento do CAMAAR
    Quando eu clicar no ícone do usuário
    E eu clicar no botão "Redefinir Senha"
    Então eu devo estar na página de gerenciamento do CAMAAR
    E um email deve ter sido enviado para "admin@example.com"
    E eu devo ver "Email de redefinição de senha enviado com sucesso!"

  Cenário: Admin redefinindo senha a partir da página de templates (HAPPY)
    Dado que eu estou logado como admin
    E que eu estou na página de gerenciamento de templates do CAMAAR
    Quando eu clicar no ícone do usuário
    E eu clicar no botão "Redefinir Senha"
    Então eu devo estar na página de gerenciamento de templates do CAMAAR
    E um email deve ter sido enviado para "admin@example.com"
    E eu devo ver "Email de redefinição de senha enviado com sucesso!"

  Cenário: Admin redefinindo senha a partir da página de resultados (HAPPY)
    Dado que eu estou logado como admin
    E que eu estou na página de resultados do CAMAAR
    Quando eu clicar no ícone do usuário
    E eu clicar no botão "Redefinir Senha"
    Então eu devo estar na página de resultados do CAMAAR
    E um email deve ter sido enviado para "admin@example.com"
    E eu devo ver "Email de redefinição de senha enviado com sucesso!"

  Cenário: Aluno redefinindo senha com sucesso (HAPPY)
    Dado que eu estou logado como aluno
    E que eu estou na página de avaliação do CAMAAR
    Quando eu clicar no ícone do usuário
    E eu clicar no botão "Redefinir Senha"
    Então eu devo estar na página de avaliação do CAMAAR
    E um email deve ter sido enviado para "aluno@example.com"
    E eu devo ver "Email de redefinição de senha enviado com sucesso!"


