#language: pt
Funcionalidade: Visualização de resultados no CAMAAR
  Eu como Administrador
  Quero visualizar os formulários criados
  A fim de poder gerar um relatório a partir das respostas

  Cenário: Visualizar formulários respondidos como admin (HAPPY)
    Dado que eu estou logado como admin
    E que existem 2 formulários respondidos
    E que eu estou na página de resultados do CAMAAR
    Então eu devo ver 2 formulários

  Cenário: Não visualizar formulários respondidos quando não houver nenhum (SAD)
    Dado que eu estou logado como admin
    E que existem 0 formulários
    E que eu estou na página de resultados do CAMAAR
    Então eu devo ver 0 formulários

  Cenário: Formulário inválido (SAD)
    Dado que eu estou logado como admin
    E que existem 1 formulários não respondidos
    E que existem 1 formulários inválidos
    E que eu estou na página de resultados do CAMAAR
    Então eu devo ver 1 formulários
    E eu devo ver "Um ou mais formulários estão incompatíveis e não podem ser visualizados"

  @javascript
  Cenário: Professor admin filtra formulários para mostrar apenas suas turmas (HAPPY)
    Dado que eu estou logado como admin professor
    E que existem 2 formulários enviados às minhas turmas
    E que existe 1 formulário enviado a outra turma
    E que eu estou na página de resultados do CAMAAR
    Quando eu clicar no botão "Mostrar apenas minhas turmas"
    Então eu devo ver apenas os formulários das minhas turmas
    Quando eu clicar no botão "Mostrar todos os formulários"
    Então eu devo ver 3 formulários

  @javascript
  Cenário: Professor admin não possui turmas com formulários (SAD)
    Dado que eu estou logado como admin professor
    E que existe 1 formulário enviado a outra turma
    E que eu estou na página de resultados do CAMAAR
    Quando eu clicar no botão "Mostrar apenas minhas turmas"
    Então eu devo ver 0 formulários
    Quando eu clicar no botão "Mostrar todos os formulários"
    Então eu devo ver 1 formulários