# language: pt
# Definição de páginas
def paginas_camaaar
  {
    "gerenciamento" => {
      path: -> { admin_gerenciamento_path },
      title: /Gerenciamento/
    },
    "avaliação" => {
      path: -> { user_avaliacoes_path },
      title: /Avaliações - CAMAAR/
    },
    "gerenciamento de templates" => {
      path: -> { admin_templates_path },
      title: /Criar ou Editar Template - CAMAAR/
    },
    "envio" => {
      path: -> { new_admin_formulario_path },
      title: /Gerenciamento - CAMAAR/
    },
    "resultados" => {
      path: -> { admin_resultados_path },
      title: /Resultados - CAMAAR/
    },
    "login" => {
      path: -> { new_pessoa_session_path },
      title: /Login - CAMAAR/
    },
    # > Não é necessário, pois seu step é mais complexo que somente estar na página de registro
    #"registro" => {                                   
    #  path: -> { edit_pessoa_password_path },
    #  title: /Defina sua Senha - CAMAAR/
    #},
  }

end

Dado(/^que eu estou logado como (.+)$/) do |pessoa|
  email = "#{pessoa}@example.com"
  senha = 'password'

  case pessoa
  when 'admin'
    @admin = FactoryBot.create(:pessoa, :admin, email: email, password: senha)
  # > Por enquanto, não foi necessário usar em nenhum caso
  #when 'admin usuário'
  #  @admin_professor = FactoryBot.create(:pessoa, :admin_professor, email: email, password: senha)   
  when 'aluno'
    @aluno = FactoryBot.create(:pessoa, :aluno, email: email, password: senha)
  when 'professor'
    @professor = FactoryBot.create(:pessoa, :professor, email: email, password: senha)
  end

  visit new_pessoa_session_path
  fill_in 'Email', with: email
  fill_in 'Senha', with: senha
  click_button 'Entrar'
end

# Checar página
Dado(/^que eu estou na página de (.+) do CAMAAR$/) do |pagina|
  config = paginas_camaaar[pagina]
  visit config[:path].call
  expect(page).to have_title(config[:title])
end

Então(/^eu devo estar na página de (.+) do CAMAAR$/) do |pagina|
  config = paginas_camaaar[pagina]
  expect(current_path).to eq config[:path].call
  expect(page).to have_title(config[:title])
end

Dado('que foram importados dados do SIGAA') do
  caminho = Rails.root.join("spec/fixtures/valido.json")
  json = JSON.parse(File.read(caminho))
  ImportadorSigaa.new(json).processar
end

# Visão de mensagens
Então(/^eu devo ver "(.*)"$/) do |mensagem|
  expect(page).to have_selector('.flash-alert, .flash-notice, .flash-success, .flash-warning, .flash-error, .success, .alert, .error', text: mensagem, visible: :visible)
end

# Visão de templates/formulários
Então(/^eu devo ver (\d+) formulários?$/) do |count|
  expect(page).to have_css('.formulario-card', count: count)
end

Então(/^eu devo ver (\d+) templates?$/) do |count|
  expect(page).to have_css('.template-card:not(.new)', count: count)
end

Quando('eu preencher o template') do
  expect(page).to have_selector('input[name="template[nome]"]')
  find('input[name="template[nome]"]').set('Template de Teste')

  expect(page).to have_selector('.pergunta')
  all('.pergunta').each_with_index do |pergunta_div, i|
    tipo_select = pergunta_div.find('select[name="questions[][type]"]', visible: false)
    tipo = tipo_select.value

    pergunta_div.find('input[name="questions[][text]"]').set("Pergunta de Teste#{i + 1}")

    if tipo == "0"
      expect(pergunta_div).to have_selector('input[name="questions[][options][]"]', count: 2)
      pergunta_div.all('input[name="questions[][options][]"]').each_with_index do |opt_input, j|
        opt_input.set("Opção #{j + 1}")
      end
    end
  end
end

Quando("eu não preencher o template") do
end

# Existem n formulários
Dado(/^que existem? (\d+) formulários?(?: não respondidos?)?$/) do |count|
  email = @aluno&.email || @admin&.email || @professor&.email || @admin_professor&.email || raise("Nenhum usuário está logado no contexto")
  pessoa = Pessoa.find_by(email: email)
  cargos = Cargo.where(email: email)

  if count > 0
    if cargos.any? { |c| [1, 2].include?(c.funcao) }
      turma = FactoryBot.create(:turma)
      Participante.create!(email: pessoa.email, id_turma: turma.id)

      count = count.to_i
      # Primeiro nome determinístico para poder escolher
      FactoryBot.create(:formulario, :com_perguntas, nome: "formulario1", turma: turma)
      # Gera o resto dos formulários normalmente
      FactoryBot.create_list(:formulario, count - 1, :com_perguntas, turma: turma) if count > 1
    else
      materia = Materia.create!(id: "#{SecureRandom.uuid}", nome: "Matéria")
      turma = Turma.create!(semestre: "2025.1", numero_turma: rand(1000..1999), professor: "Prof. Nome", id_materia: materia.id)
      ligacao = LigacaoPergunta.create!

      count.to_i.times do |i|
        Formulario.create!(nome: "Formulario Não Respondido #{i + 1} - #{SecureRandom.hex(3)}", turma: turma, ligacao_pergunta: ligacao)
      end
    end
  end

end

Dado(/^que existem? (\d+) formulários? respondidos?$/) do |count|
  email = @aluno&.email || @admin&.email || raise("Nenhum usuário está logado no contexto")
  pessoa = Pessoa.find_by(email: email)
  cargos = Cargo.where(email: email)

  if cargos.any? { |c| [1, 2].include?(c.funcao) }
    puts "QAAOASOIDHAOIHDIOASDIO"
    turma = FactoryBot.create(:turma)                                                                    # <----
    Participante.create!(email: pessoa.email, id_turma: turma.id)                                        # <----

    count.to_i.times do                                                                                  # <----
      formulario = FactoryBot.create(:formulario, :com_perguntas, turma: turma)                          # <----
      formulario.ligacao_pergunta.perguntas.each do |pergunta|                                           # <----
        conteudo = pergunta.tipo == 0 ? "a" : "Alguma resposta"                                          # <----
        FactoryBot.create(:resposta, formulario: formulario, pergunta: pergunta, conteudo: conteudo)     # <----
      end 
      FormularioRespondido.create!(formulario: formulario, email: pessoa.email)                          # <----
    end
  else
    materia = Materia.create!(id: "#{SecureRandom.uuid}", nome: "Matéria")
    turma = Turma.create!(semestre: "2025.1", numero_turma: rand(100..999), professor: "Prof. Nome", id_materia: materia.id)
    ligacao = LigacaoPergunta.create!

    count.to_i.times do |i|
      formulario = Formulario.create!(nome: "Formulario Respondido #{i + 1} - #{SecureRandom.hex(3)}", turma: turma, ligacao_pergunta: ligacao)
      pergunta = Pergunta.create!(ligacao_pergunta: ligacao, tipo: 1, pergunta: "Pergunta #{i + 1}")
      Resposta.create!(formulario: formulario, pergunta: pergunta, conteudo: "Resposta #{i + 1}")
    end
  end
end

Dado(/^que existem? (\d+) formulários? inválidos?$/) do |count|
  email = @aluno&.email || @admin&.email || raise("Nenhum usuário está logado no contexto")
  pessoa = Pessoa.find_by(email: email)
  cargos = Cargo.where(email: email)

  if cargos.any? { |c| [1, 2].include?(c.funcao) }
    turma = FactoryBot.create(:turma)
    Participante.create!(email: pessoa.email, id_turma: turma.id)

    FactoryBot.create_list(:formulario, count.to_i, :invalido, turma: turma)
  else
    materia = Materia.create!(id: "#{SecureRandom.uuid}", nome: "Matéria")
    turma = Turma.create!(semestre: "2025.1", numero_turma: rand(2000..2999), professor: "Prof. Nome", id_materia: materia.id)
    ligacao = LigacaoPergunta.create!

    count.to_i.times do
      FactoryBot.create_list(:formulario, count.to_i, :invalido, turma: turma,ligacao_pergunta: ligacao)
      #Formulario.create!(nome: "", turma: turma, ligacao_pergunta: ligacao)
    end
  end
end

# Seleção pra resposta de formulário e resposta de formulário
Quando(/^eu clicar no formulário "(.*)"$/) do |form_name|
  within('.formularios-list') do
    within(:xpath, ".//div[contains(@class, 'formulario-card')][.//strong[text()='#{form_name}']]") do
      click_link 'Responder'
    end
  end
end

Quando('eu preencher o formulário') do
  all('.pergunta').each do |pergunta_div|
    if pergunta_div.has_selector?('input[type="radio"]', wait: false)
      pergunta_div.find('input[type="radio"]', match: :first).click
    elsif pergunta_div.has_selector?('textarea', wait: false)
      pergunta_div.find('textarea').set('Resposta de teste')
    end
  end
end

# Importar dados

Quando('eu selecionar o arquivo {string}') do |nome_arquivo|
  caminho = Rails.root.join("spec/fixtures/#{nome_arquivo}")
  attach_file('file', caminho)  # o nome do campo no formulário é :file
end

Então('um email deve ter sido enviado para {string}') do |email|
  mail = ActionMailer::Base.deliveries.find { |m| m.to.include?(email) }
  expect(mail).not_to be_nil
  expect(mail.subject).to match(/Definição de Senha - CAMAAR/i)
end


# Enviar formulário
Dado("que existe um template chamado {string}") do |nome_template|
  ligacao = LigacaoPergunta.create!
  Pergunta.create!(pergunta: "Pergunta de exemplo", tipo: 1, ligacao_pergunta_id: ligacao.id)
  Template.create!(nome: nome_template, ligacao_pergunta_id: ligacao.id)
end

Dado("que existe uma matéria chamada {string}") do |nome_materia|
  materia = Materia.create!(id: "MAT01", nome: nome_materia)
  Turma.create!(semestre: "2025.1", numero_turma: 1, professor: "Prof. X", id_materia: materia.id)
end

Quando(/^eu escolher o template "(.*)"$/) do |nome_template|
  select nome_template, from: "Template"
end

Quando(/^eu selecionar a matéria "(.*)"$/) do |nome_materia|
  materia_row = find('tr', text: nome_materia)
  materia_row.find('input[type="checkbox"]').click
end

Quando("eu clicar no botão “Enviar”") do
  click_button "Enviar"
end

# Templates

Dado('que existem {int} templates') do |quantidade|
  quantidade.times do |i|
    ligacao = LigacaoPergunta.create!

    Pergunta.create!(pergunta: "Pergunta #{i+1}", ligacao_pergunta_id: ligacao.id, tipo: 1)
    Template.create!(ligacao_pergunta_id: ligacao.id, nome: "Template #{i+1}")

  end
end

Dado('que existem {int} templates inválido') do |quantidade|
  quantidade.times do |i|
    ligacao = LigacaoPergunta.create!

    Template.create!(ligacao_pergunta_id: ligacao.id, nome: "Template inválido #{i + 1}")
  end
end

Quando('eu clicar no botão {string}') do |botao|
  click_on botao
end

Dado('que o template {string} foi excluído por outro admin enquanto eu estava na tela') do |template_nome|
  template = Template.find_by(nome: template_nome)
  raise "Template '#{template_nome}' não encontrado" unless template

  template.destroy!
end

Quando('eu clicar no botão {string} no template {string}') do |botao, nome_template|
  within('.templates-list') do
    template_card = find('.template-card', text: nome_template)
    raise "Template '#{nome_template}' não encontrado" unless template_card

    if botao.downcase == 'excluir'
      accept_confirm("Tem certeza que deseja excluir o template #{nome_template}?") do
        template_card.find('input.btn-delete', match: :first).click
      end

    else
      within(template_card) do
        click_on botao
      end
    end
  end
end

Então('eu não devo ver o template {string}') do |texto|
  within('.templates-list') do
    expect(page).not_to have_content(texto)
  end
end

Então('nenhum template deve ser exibido na lista') do
  expect(page).not_to have_selector('.formulario-card')
end


# Relatório
Quando(/^eu clicar em "Download" em um formulário não respondido$/) do
  within('.formularios-list') do
    first('.formulario-card.nao-respondido').click_link('Download')
  end
end

Quando(/^eu clicar em "Download" em um formulário respondido$/) do
  within('.formularios-list') do
    first('.formulario-card:not(.nao-respondido)').click_link('Download')
  end
end

Então(/^um arquivo "\.csv" deve ser baixado$/) do
  iframe = find('iframe', visible: false)
  src = iframe[:src]
  uri = URI(src)
  path = uri.path
  path += "?#{uri.query}" if uri.query

  download_response = page.driver.get(path)
  expect(download_response.headers['Content-Disposition'])
    .to include('attachment')
  expect(download_response.headers['Content-Type'])
    .to eq('text/csv')
end

# Login
Dado(/^que existe um (.+) cadastrado com "(.+)" e "(.+)"$/) do |tipo, email, senha|
  valid_traits = %w[aluno admin professor admin_professor]
  tipo_normalizado = tipo.downcase

  raise ArgumentError, "Tipo inválido: #{tipo}" unless valid_traits.include?(tipo_normalizado)

  FactoryBot.create(:pessoa, tipo_normalizado.to_sym, email: email, password: senha, password_confirmation: senha)
end

Quando('eu preencher o campo {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
end

# Senha
Dado('que eu estou na página de registro do CAMAAR com um token válido') do
  include ActionMailer::TestHelper
  Devise.mappings[:pessoa] ||= Devise::Mapping.new(:pessoa, {})
  ActionMailer::Base.deliveries.clear
  pessoa = FactoryBot.create(:pessoa, email: "myemail@email", password: nil)
  raw_token, enc_token = Devise.token_generator.generate(Pessoa, :reset_password_token)
  pessoa.update!(
    reset_password_token: enc_token,
    reset_password_sent_at: Time.current
  )
  Devise::Mailer.reset_password_instructions(pessoa, raw_token).deliver_now
  mail = ActionMailer::Base.deliveries.last
  link = mail.body.encoded.match(/href="(?<url>.+?)"/)[:url]
  token = CGI.parse(URI.parse(link).query)["reset_password_token"].first
  visit edit_pessoa_password_path(reset_password_token: token)
end

Dado('que eu estou na página de registro do CAMAAR com um token inválido') do
  visit edit_pessoa_password_path(reset_password_token: "token_invalido")
end

Então('deve existir uma pessoa cadastrada com {string} e {string}') do |email, senha|
  pessoa = Pessoa.find_by(email: email)
  expect(pessoa.valid_password?(senha)).to be(true)
end

# Steps para redefinição de senha
Quando('eu clicar no ícone do usuário') do
  find('.user-icon').click
end
