# spec/features/gerar_relatorio_spec.rb
require 'rails_helper'

RSpec.describe 'Gerar relatório do administrador', type: :feature do
  before do
  end

  def criar_formulario_respondido
    materia = Materia.create!(id: SecureRandom.uuid, nome: 'Matéria')
    turma = Turma.create!(semestre: '2025.1', numero_turma: rand(100..999), professor: 'Prof. Nome', id_materia: materia.id)
    ligacao = LigacaoPergunta.create!

    formulario = Formulario.create!(nome: "Formulario Respondido - #{SecureRandom.hex(3)}", turma: turma, ligacao_pergunta: ligacao)
    pergunta = Pergunta.create!(ligacao_pergunta: ligacao, tipo: 1, pergunta: 'Pergunta 1')
    Resposta.create!(formulario: formulario, pergunta: pergunta, conteudo: 'Resposta 1')
  end

  def criar_formulario_nao_respondido
    materia = Materia.create!(id: SecureRandom.uuid, nome: 'Matéria')
    turma = Turma.create!(semestre: '2025.1', numero_turma: rand(1000..1999), professor: 'Prof. Nome', id_materia: materia.id)
    ligacao = LigacaoPergunta.create!

    Formulario.create!(nome: "Formulario Não Respondido - #{SecureRandom.hex(3)}", turma: turma, ligacao_pergunta: ligacao)
  end

  scenario 'Baixar resultados com sucesso (HAPPY)' do
    criar_formulario_respondido
    criar_formulario_nao_respondido

    visit admin_resultados_path

    within('.formularios-list') do
      first('.formulario-card:not(.nao-respondido)').click_link('Download')
    end

    expect(current_path).to eq(admin_resultados_path)

    iframe = find('iframe', visible: false)
    src = iframe[:src]
    uri = URI(src)
    path = uri.path
    path += "?#{uri.query}" if uri.query

    download_response = page.driver.get(path)

    expect(download_response.headers['Content-Disposition']).to include('attachment')
    expect(download_response.headers['Content-Type']).to eq('text/csv')

    expect(page).to have_content('Arquivo de resultado baixado com sucesso')
  end

  scenario 'Tentar baixar resultados de um formulário sem respostas (SAD)' do
    criar_formulario_nao_respondido

    visit admin_resultados_path

    within('.formularios-list') do
      first('.formulario-card.nao-respondido').click_link('Download')
    end

    expect(current_path).to eq(admin_resultados_path)
    expect(page).to have_content('Este formulário ainda não contém respostas')
  end
end

