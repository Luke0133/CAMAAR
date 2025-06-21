#language: pt
Funcionalidade: Gerar relatório do administrador
Eu como Administrador
Quero baixar um arquivo csv contendo os resultados de um formulário
A fim de avaliar o desempenho das turmas

  Contexto:
    Dado que eu estou logado como admin
    E que eu estou na página de gerenciamento do CAMAAR
    E que existe(m) 1 formulário(s) respondido(s)
    Quando eu clicar no botão "Resultados"
    E eu clicar no "formulario1"
    Então eu devo estar na página de resultados do CAMAAR

  Cenário: Baixar resultados com sucesso (HAPPY)
    E o arquivo "formulario1.csv" deve ser baixado
    E eu devo ver "Arquivo de resultado baixado com sucesso"

  Cenário: Tentar baixar resultados de um formulario sem respostas (SAD)
    E eu devo ver "Este formulário ainda não contém respostas"