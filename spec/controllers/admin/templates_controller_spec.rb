require 'rails_helper'

RSpec.describe Admin::TemplatesController, type: :controller do
  let(:admin) { create(:pessoa, email: "admin@camaar.com",) }

  let(:valid_attributes) do
    {
      nome: 'Template de Teste'
    }
  end

  let(:invalid_attributes) do
    {
      nome: ''
    }
  end

  let(:valid_questions) do
    [
      {
        text:    'Pergunta de Teste1',
        type:    '0',
        options: ['Opção 1', 'Opção 2']
      },
      {
        text: 'Pergunta de Teste2',
        type: '1'
      }
    ]
  end

  before do
    session[:email] = admin.email
    get :index
  end

  describe "GET #index" do
    context "com templates válidos e inválidos" do
      let!(:templates_validos) do
        3.times.map do |i|
          ligacao = create(:ligacao_pergunta)
          create(:pergunta, ligacao_pergunta: ligacao)
          create(:template, nome: "Template #{i+1}", ligacao_pergunta: ligacao)
        end
      end

      let!(:templates_invalidos) do
        2.times.map do |i|
          ligacao = create(:ligacao_pergunta) # sem perguntas
          create(:template, nome: "Inválido #{i+1}", ligacao_pergunta: ligacao)
        end
      end

      it "atribui apenas os templates válidos" do
        get :index
        expect(assigns(:valid_templates)).to match_array(templates_validos)
        expect(assigns(:valid_templates)).not_to include(*templates_invalidos)
      end

      it "define o alerta se houver templates inválidos" do
        get :index
        expect(assigns(:show_incompatibility_message)).to be(true)


      end

      it "renderiza a view de index" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context "sem templates inválidos" do
      before do
        # Apenas templates válidos
        2.times do |i|
          ligacao = create(:ligacao_pergunta)
          create(:pergunta, ligacao_pergunta: ligacao)
          create(:template, nome: "Template #{i+1}", ligacao_pergunta: ligacao)
        end
      end

      it "não define flash de alerta" do
        get :index
       expect(assigns(:show_incompatibility_message)).to be(false)
      end
    end
  end

  describe 'GET #new' do
    it 'renderiza os campos de um novo template' do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(assigns(:template)).to be_a_new(Template)
    end
  end

  describe 'POST #create' do
    context 'com parâmetros válidos' do
      it 'cria template novo' do
        expect {
          post :create, params: { template: valid_attributes, questions: valid_questions }
        }.to change(Template, :count).by(1)
      end

      it 'redireciona ao gerenciamento de templates com um aviso' do
        post :create, params: { template: valid_attributes, questions: valid_questions }
        expect(response).to redirect_to(admin_templates_path)
        expect(flash[:success]).to match(/Template criado com sucesso!/i)
      end
    end

    context 'com parâmetros inválidos' do
      it 'não cria template novo' do
        expect {
          post :create, params: { template: invalid_attributes, questions: valid_questions }
        }.not_to change(Template, :count)
      end

      it 'mantém na página de criação, com erro' do
        post :create, params: { template: invalid_attributes, questions: valid_questions }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(flash[:error])
      end
    end
  end

  describe 'GET #edit' do
    let!(:template) { FactoryBot.create(:template) }

    context 'quando o template existe' do
      # Gera exemplos de perguntas para verificar se estão sendo recebidas corretamente
      let(:ligacao)  { create(:ligacao_pergunta) }
      let(:template) { create(:template, ligacao_pergunta: ligacao) }
      let!(:pergunta) { create(:pergunta, ligacao_pergunta: ligacao, pergunta: "Qual a cor?", tipo: 0) }
      let!(:opcao1)   { create(:opcao, pergunta: pergunta, opcao: "Azul", item: 1) }
      let!(:opcao2)   { create(:opcao, pergunta: pergunta, opcao: "Vermelho", item: 2) }

      before do
        get :edit, params: { id: template.id }
      end
      
      it 'renderiza os campos de um template' do
        get :edit, params: { id: template.id }

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:edit)
        expect(assigns(:template)).to eq(template)

        # Checa se perguntas mockadas estão corretas
        expect(assigns(:questions)).to eq([
          {
            pergunta: "Qual a cor?",
            tipo: "0",
            opcoes: [
              { opcao: "Azul" },
              { opcao: "Vermelho" }
            ]
          }
        ])
      end
    end

    context 'quando o template foi excluído por outro admin' do
      it 'redireciona para index com alerta' do
        template.destroy
        get :edit, params: { id: template.id }
        expect(response).to redirect_to(admin_templates_path)
        expect(flash[:error]).to match(/Falha ao editar: o template selecionado não existe/i)
      end
    end
  end

  describe 'PUT #update' do
    let!(:template) { FactoryBot.create(:template) }
    let(:new_attributes) { { nome: 'Template Atualizado' } }

    context 'com parâmetros válidos' do
      it 'atualiza o template requerido' do
        put :update, params: { id: template.id, template: new_attributes, questions: valid_questions }
        template.reload
        expect(template.nome).to eq('Template Atualizado')
      end

      it 'redireciona para index com uma mensagem de sucesso' do
        put :update, params: { id: template.id, template: new_attributes, questions: valid_questions }
        expect(response).to redirect_to(admin_templates_path)
        expect(flash[:success]).to match(/Template atualizado com sucesso!/i)
      end
    end

    context 'quando o template foi excluído por outro admin' do
      it 'redireciona com um alerta' do
        template.destroy
        put :update, params: { id: template.id, template: new_attributes }
        expect(response).to redirect_to(admin_templates_path)
        expect(flash[:error]).to match(/Falha ao editar: o template selecionado não existe/i)
      end
    end

    context 'com parâmetros inválidos' do
      it 'mantém na página de edição, com erro' do
        put :update, params: { id: template.id, template: invalid_attributes, questions: valid_questions }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
        expect(flash[:error])
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:template) { FactoryBot.create(:template) }

    context 'quando o template existe' do
      it 'destrói o template requerido' do
        expect {
          delete :destroy, params: { id: template.id }
        }.to change(Template, :count).by(-1)
      end

      it 'redireciona para a index com uma mensagem de sucesso' do
        delete :destroy, params: { id: template.id }
        expect(response).to redirect_to(admin_templates_path)
        expect(flash[:warning]).to match(/O template ".*" foi excluído!/i)
      end
    end

    context 'quando o template foi excluído por outro admin' do
      it 'redireciona com um alerta' do
        template.destroy
        expect {
          delete :destroy, params: { id: template.id }
        }.not_to change(Template, :count)
        expect(response).to redirect_to(admin_templates_path)
        expect(flash[:error]).to match(/Falha ao excluir: o template selecionado não existe/i)
      end
    end
  end
end
