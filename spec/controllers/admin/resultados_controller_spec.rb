require 'rails_helper'

RSpec.describe Admin::ResultadosController, type: :controller do
  let(:admin) { create(:pessoa, :admin) }

  before do
    session[:email] = admin.email
  end
  
  def criar_formularios_respondidos(count)
    ligacao = create(:ligacao_pergunta)
    turma = create(:turma)

    count.times do |i|
      create(:formulario, :com_respostas, nome: "Respondido #{i + 1}", turma: turma, ligacao_pergunta: ligacao)
    end
  end

  def criar_formularios_nao_respondidos(count)
    ligacao = create(:ligacao_pergunta)
    turma = create(:turma)

    count.times do |i|
      create(:formulario, nome: "Não respondido #{i + 1}", turma: turma, ligacao_pergunta: ligacao)
    end
  end

  def criar_formularios_invalidos(count)
    ligacao = create(:ligacao_pergunta)
    turma = create(:turma)

    count.times do
      Formulario.create!(nome: "", turma: turma, ligacao_pergunta: ligacao)
    end
  end

  describe 'GET #index' do
    context 'HAPPY: com formulários respondidos' do
      it 'retorna os formulários respondidos' do
        criar_formularios_respondidos(2)

        get :index

        expect(assigns(:forms).count).to eq(2)
        expect(response).to have_http_status(:success)
      end
    end

    context 'SAD: nenhum formulário respondido' do
      it 'retorna lista vazia' do
        get :index

        expect(assigns(:forms)).to be_empty
        expect(response).to have_http_status(:success)
      end
    end

    context 'SAD: há inválidos e respondidos' do
      it 'retorna os válidos e sinaliza erro' do
        criar_formularios_nao_respondidos(1)
        criar_formularios_invalidos(1)
        criar_formularios_respondidos(1)

        get :index

        expect(assigns(:forms).count).to eq(2)
        expect(flash[:error]).to eq('Um ou mais formulários estão incompatíveis e não podem ser visualizados.')
      end
    end
  end

  describe 'GET #download' do
    context 'HAPPY: quando o formulário possui respostas' do
      it 'retorna o arquivo CSV para download' do
        formulario = create(:formulario, :com_respostas, nome: 'Formulário 1')

        get :download, params: { id: formulario.id }

        expect(response).to have_http_status(:success)
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Type']).to eq('text/csv')
      end
    end

    context 'SAD: quando o formulário não possui respostas' do
      it 'redireciona com mensagem de erro' do
        formulario = create(:formulario, :sem_respostas, nome: 'Formulário 2')

        get :download, params: { id: formulario.id }

        expect(response).to redirect_to(admin_resultados_path)
        expect(flash[:warning]).to eq('Este formulário ainda não contém respostas')
      end
    end
  end
end