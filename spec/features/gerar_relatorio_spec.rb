require 'rails_helper'

RSpec.describe Admin::ResultadosController, type: :controller do
  let(:admin) { create(:pessoa, :admin) }

  before do
    session[:email] = admin.email
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