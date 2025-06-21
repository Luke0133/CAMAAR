#language: pt

Funcionalidade: Visualização dos templates criados
  Eu como Administrador
  Quero visualizar os templates criados
  A fim de poder editar e/ou deletar um template que eu criei

  Contexto:
    Dado que eu estou logado como admin
    E que eu estou na página inicial de gerenciamento do CAMAAR

  Cenário: Visualizar e editar templates como admin
    E que existe(m) 2 template(s)
    Quando eu clicar no botão "Editar templates"
    Então eu devo estar na página de gerenciamento de templates do CAMAAR
    E eu devo ver 2 template(s)

  Cenário: Não visualizar templates inválidos como admin
    E que existe(m) 1 template(s)
    E que existe 1 template(s) inválido(s)
    Quando eu clicar no botão "Editar templates"
    Então eu devo estar na página de gerenciamento de templates do CAMAAR
    E eu devo ver 0 template(s)
    E eu devo ver "Um ou mais templates estão incompatíveis e não podem ser visualizados"