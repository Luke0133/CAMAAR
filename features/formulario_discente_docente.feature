#language: pt
Funcionalidade: Criação de formulário para docentes ou dicentes
  Eu como Administrador
  Quero escolher criar um formulário para os docentes ou os dicentes de uma turma
  A fim de avaliar o desempenho de uma matéria

  # Lado do admin:
  Cenário: Criação de um formulário de avaliação bem-sucedida (HAPPY) - aluno
    Dado que eu estou logado como admin
    E que existe um template chamado "template_teste"
    E que existe uma matéria chamada "materia_teste"
    E que eu estou na página de envio do CAMAAR
    Quando eu escolher o template "template_teste"
    E eu selecionar a matéria "materia_teste"
    E eu clicar no botão "Aluno"
    E eu clicar no botão “Enviar”
    Então eu devo estar na página de gerenciamento do CAMAAR
    E eu devo ver "Formulário enviado com sucesso"

  Cenário: Criação de um formulário de avaliação bem-sucedida (HAPPY) - aluno
    Dado que eu estou logado como admin
    E que existe um template chamado "template_teste"
    E que existe uma matéria chamada "materia_teste"
    E que eu estou na página de envio do CAMAAR
    Quando eu escolher o template "template_teste"
    E eu selecionar a matéria "materia_teste"
    E eu clicar no botão "Professor"
    E eu clicar no botão “Enviar”
    Então eu devo estar na página de gerenciamento do CAMAAR
    E eu devo ver "Formulário enviado com sucesso"

  # Lado do usuário
  Cenário: Existem formulários não respondidos HAPPY - aluno
    Dado que eu estou logado como aluno
    E que existem 2 formulários não respondidos para alunos
    E que existem 1 formulários não respondidos para professores
    E que eu estou na página de avaliação do CAMAAR
    Então eu devo ver 2 formulários

  Cenário: Não existem formulários não respondidos HAPPY - aluno
    Dado que eu estou logado como aluno
    E que existem 0 formulários não respondidos para alunos
    E que existem 1 formulários não respondidos para professores
    E que eu estou na página de avaliação do CAMAAR
    Então eu devo ver 0 formulários
  
  Cenário: Existem formulários não respondidos HAPPY - professor
    Dado que eu estou logado como professor
    E que existem 2 formulários não respondidos para alunos
    E que existem 1 formulários não respondidos para professores
    E que eu estou na página de avaliação do CAMAAR
    Então eu devo ver 1 formulários

  Cenário: Não existem formulários não respondidos HAPPY - professor
    Dado que eu estou logado como professor
    E que existem 2 formulários não respondidos para alunos
    E que existem 0 formulários não respondidos para professores
    E que eu estou na página de avaliação do CAMAAR
    Então eu devo ver 0 formulários