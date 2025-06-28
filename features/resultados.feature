#language: pt
Funcionalidade: Visualização de resultados no CAMAAR
  Eu como Administrador
  Quero visualizar os formulários criados
  A fim de poder gerar um relatório a partir das respostas

  Contexto:
    Dado que eu estou logado como admin
    E que eu estou na página de resultados do CAMAAR

  Cenário: Visualizar formulários respondidos como admin (HAPPY)
    E que existe(m) 2 formulário(s) respondido(s)
    Então eu devo ver 2 formulário(s)

  Cenário: Não visualizar formulários respondidos quando não houver nenhum (SAD)
    E que existe(m) 0 formulário(s) respondido(s)
    Então eu devo ver 0 formulário(s)

  Cenário: Formulário inválido (SAD)
    E que existe(m) 1 formulário(s) não respondido(s)
    E que existe(m) 1 formulário(s) inválido(s)
    Então eu devo ver 0 formulário(s)
    E eu devo ver "Um ou mais formulários estão incompatíveis e não podem ser visualizados"