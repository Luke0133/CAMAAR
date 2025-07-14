# spec/features/resultados_spec.rb
require 'rails_helper'

RSpec.describe 'Visualização de Resultados no CAMAAR', type: :feature do
  before do
  end

  def criar_formularios_respondidos(count)
    materia = Materia.create!(id: SecureRandom.uuid, nome: 'Matéria')
    turma = Turma.create!(semestre: '2025.1', numero_turma: rand(100..999), professor: 'Prof. Nome', id_materia: materia.id)
    ligacao = LigacaoPergunta.create!

    count.times do |i|
      formulario = Formulario.create!(nome: "Formulario Respondido #{i + 1} - #{SecureRandom.hex(3)}", turma: turma, ligacao_pergunta: ligacao)
      pergunta = Pergunta.create!(ligacao_pergunta: ligacao, tipo: 1, pergunta: "Pergunta #{i + 1}")
      Resposta.create!(formulario: formulario, pergunta: pergunta, conteudo: "Resposta #{i + 1}")
    end
  end

  def criar_formularios_nao_respondidos(count)
    materia = Materia.create!(id: SecureRandom.uuid, nome: 'Matéria')
    turma = Turma.create!(semestre: '2025.1', numero_turma: rand(1000..1999), professor: 'Prof. Nome', id_materia: materia.id)
    ligacao = LigacaoPergunta.create!

    count.times do |i|
      Formulario.create!(nome: "Formulario Não Respondido #{i + 1} - #{SecureRandom.hex(3)}", turma: turma, ligacao_pergunta: ligacao)
    end
  end

  def criar_formularios_invalidos(count)
    materia = Materia.create!(id: SecureRandom.uuid, nome: 'Matéria')
    turma = Turma.create!(semestre: '2025.1', numero_turma: rand(2000..2999), professor: 'Prof. Nome', id_materia: materia.id)
    ligacao = LigacaoPergunta.create!

    count.times do
      Formulario.create!(nome: nil, turma: turma, ligacao_pergunta: ligacao)
    end
  end

  scenario 'Visualizar formulários respondidos como admin (HAPPY)' do
    criar_formularios_respondidos(2)

    visit admin_resultados_path

    expect(page).to have_css('.formulario-card', count: 2)
  end

  scenario 'Não visualizar formulários respondidos quando não houver nenhum (SAD)' do
    visit admin_resultados_path

    expect(page).to have_css('.formulario-card', count: 0)
  end

  scenario 'Formulário inválido (SAD)' do
    criar_formularios_nao_respondidos(1)
    criar_formularios_invalidos(1)
    criar_formularios_respondidos(1)

    visit admin_resultados_path

    expect(page).to have_css('.formulario-card', count: 2)
    expect(page).to have_content('Um ou mais formulários estão incompatíveis e não podem ser visualizados')
  end
end