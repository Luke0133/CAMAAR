#language: pt
Funcionalidade: Responder Formulário
Eu como participante de uma turma
Quero responder o questionário sobre a turma em que estou matriculado
A fim de submeter minha avaliação de turma

  Contexto:
    Dado que eu estou na página de avaliações do CAMAAR
    E que existe(m) 1 formulário(s) não respondido(s)

  Cenário: Resposta bem-sucedida do admin (HAPPY)
    E que eu estou logado como admin
    Quando eu clicar no "formulario1"
    E eu preencher o formulário
    E eu clicar no botão "Enviar"
    Então eu devo ir para a página de avaliações do CAMAAR
    E eu devo ver "Resposta enviada com sucesso"

  Cenário: Resposta bem-sucedida do usuário comum (HAPPY)
    E que eu estou logado como usuário
    Quando eu clicar no "formulario1"
    E eu preencher o formulário
    E eu clicar no botão "Enviar"
    Então eu devo ir para a página de avaliações do CAMAAR
    E eu devo ver "Resposta enviada com sucesso"

  Cenário: Envio de formulário incompleto pelo admin (SAD)
    E que eu estou logado como admin
    Quando eu clicar no "formulario1"
    E eu não preencher formulário
    E eu clicar no botão "Enviar"
    Então eu devo ver a mensagem "Todos os campos precisam ser preenchidos"

  Cenário: Envio de formulário incompleto pelo usuário comum (SAD)
    E que eu estou logado como usuário
    Quando eu clicar no "formulario1"
    E eu não preencher formulário
    E eu clicar no botão "Enviar"
    Então eu devo ver a mensagem "Todos os campos precisam ser preenchidos"