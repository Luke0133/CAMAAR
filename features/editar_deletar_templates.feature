#language: pt
Funcionalidade: Edição e deleção de templates
  Eu como Administrador
  Quero editar e/ou deletar um template que eu criei sem afetar os formulários já criados
  A fim de organizar os templates existentes

  Contexto:
    Dado que eu estou logado como admin
    E que existe um template chamado "Template1"
    E que eu estou na página de gerenciamento de templates do CAMAAR

  @javascript
  Cenário: Excluir um template com sucesso (HAPPY)
    Quando eu clicar no botão "Excluir" no template "Template1"
    Então eu devo estar na página de gerenciamento de templates do CAMAAR
    E eu devo ver "O template "Template1" foi excluído!"
    E eu não devo ver o template "Template1"

  @javascript
  Cenário: Editar um template com sucesso (HAPPY)
    Quando eu clicar no botão "Editar" no template "Template1"
    E eu preencher o template
    E eu clicar no botão "Salvar Template"
    Então eu devo estar na página de gerenciamento de templates do CAMAAR
    E eu devo ver "Template atualizado com sucesso"

  @javascript
  Cenário: Falha ao excluir um template que foi excluído por outro admin
    Dado que o template "Template1" foi excluído por outro admin enquanto eu estava na tela
    Quando eu clicar no botão "Excluir" no template "Template1"
    Então eu devo estar na página de gerenciamento de templates do CAMAAR
    E eu devo ver "Falha ao excluir: o template selecionado não existe."
    E eu não devo ver o template "Template1"

  Cenário: Falha ao editar um template que foi excluído por outro admin
    Dado que o template "Template1" foi excluído por outro admin enquanto eu estava na tela
    Quando eu clicar no botão "Editar" no template "Template1"
    Então eu devo estar na página de gerenciamento de templates do CAMAAR
    E eu devo ver "Falha ao editar: o template selecionado não existe."
    E eu não devo ver o template "Template1"