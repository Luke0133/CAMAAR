#language: pt

Funcionalidade: Criar templates para formulários
  Eu como Administrador
  Quero criar um template de formulário contendo as questões do formulário
  A fim de gerar formulários de avaliações para avaliar o desempenho das turmas

  Contexto:
    Dado que eu estou logado como admin
    E que eu estou na página de gerenciamento de templates do CAMAAR

  @javascript
  Cenário: Criação do template com sucesso (HAPPY)
    E que existem 0 templates
    Quando eu clicar no botão "Novo template"
    E eu preencher o template
    E eu clicar no botão "Salvar Template"
    Então eu devo estar na página de gerenciamento de templates do CAMAAR
    E eu devo ver 1 template

  @javascript
  Cenário: Preenchimento incompleto de informações para criar template (SAD)
    Quando eu clicar no botão "Novo template"
    E eu não preencher o template
    E eu clicar no botão "Salvar Template"
    Então eu devo ver "Erro(s) no template: O nome do template não pode estar em branco; Deve haver pelo menos uma pergunta e todas devem ter texto; Todas as opções de todas as perguntas devem estar preenchidas."
