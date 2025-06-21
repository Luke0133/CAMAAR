#language: pt
Funcionalidade: Visualização de formulários para responder
  Eu como Participante de uma turma
  Quero visualizar os formulários não respondidos das turmas em que estou matriculado
  A fim de poder escolher qual irei responder

  Contexto:
    Dado que eu estou logado como aluno
    E que eu estou na página de avaliação do CAMAAR

  Cenário: Existem formulários não respondidos (HAPPY)
    E que existe(m) 2 formulário(s) não respondido(s)
    Então eu devo ver 2 formulário(s)

  Cenário: Não existem formulários não respondidos (HAPPY)
    E que existe(m) 0 formulário(s) não respondido(s)
    Então eu devo ver 0 formulário(s)

  Cenário: Formulário inválido (SAD)
    E que existe(m) 1 formulário(s) não respondido(s)
    E que existe(m) 1 formulário(s) inválido(s)
    Então eu devo ver 0 formulário(s)
    E eu devo ver "Um ou mais formulários estão incompatíveis e não podem ser visualizados"