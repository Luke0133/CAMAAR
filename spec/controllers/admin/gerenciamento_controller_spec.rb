require 'rails_helper'

RSpec.describe Admin::GerenciamentoController, type: :controller do
  render_views

  let(:admin) { create(:pessoa, email: "admin@camaar.com") }

  before do
    session[:email] = admin.email
  end

  describe "GET #index" do
    context "sem dados no sistema" do
      it "atribui as permissões corretamente como falsas" do
        get :index

        expect(assigns(:can_edit_templates)).to be false
        expect(assigns(:can_send_formularios)).to be false
        expect(assigns(:can_view_resultados)).to be false
        expect(response).to render_template(:index)
      end
    end

    context "com permissões e dados" do
      it "atribui as permissões corretamente como verdadeiras" do
        pessoa1 = create(:pessoa)
        pessoa2 = create(:pessoa)
        create(:cargo, pessoa: pessoa1, funcao: 1)
        create(:cargo, pessoa: pessoa2, funcao: 2)
        create(:template)
        create(:formulario)

        get :index

        expect(assigns(:can_edit_templates)).to be true
        expect(assigns(:can_send_formularios)).to be true
        expect(assigns(:can_view_resultados)).to be true
      end
    end
  end

  describe "POST #importar" do
    let(:valid_data) { { "materias" => [], "turmas" => [] } }
    let(:temp_file) do
      tempfile = Tempfile.new(['dados', '.json'])
      tempfile.write(valid_data.to_json)
      tempfile.rewind
      Rack::Test::UploadedFile.new(tempfile.path, "application/json")
    end

    it "importa com sucesso e exibe mensagem sem atualização" do
      importador = instance_double(ImportadorSigaa, processar: false)
      allow(ImportadorSigaa).to receive(:new).and_return(importador)

      post :importar, params: { file: temp_file }

      expect(response).to redirect_to(admin_gerenciamento_path)
      expect(flash[:notice]).to eq("Dados importados com sucesso")
    end

    it "importa com sucesso e exibe mensagem de atualização" do
      importador = instance_double(ImportadorSigaa, processar: true)
      allow(ImportadorSigaa).to receive(:new).and_return(importador)

      post :importar, params: { file: temp_file }

      expect(response).to redirect_to(admin_gerenciamento_path)
      expect(flash[:notice]).to eq("Dados importados com sucesso")
    end

    context "arquivo com extensão incorreta" do
      let(:fake_file) do
        fixture_file_upload(Rails.root.join("spec/fixtures/invalido.txt"), "text/plain")
      end
      
      it "retorna erro com extensão incorreta" do
        post :importar, params: { file: fake_file }

        expect(response).to redirect_to(admin_gerenciamento_path)
        expect(flash[:alert]).to eq("Falha ao importar dados: arquivo com extensão incorreta")
      end
    end

    it "retorna erro com JSON inválido" do
      tempfile = Tempfile.new(['dados', '.json'])
      tempfile.write("INVALID_JSON")
      tempfile.rewind
      json_file = Rack::Test::UploadedFile.new(tempfile.path, "application/json")

      post :importar, params: { file: json_file }

      expect(response).to redirect_to(admin_gerenciamento_path)
      expect(flash[:alert]).to eq("Falha ao importar dados: dados do arquivo em formato inválido")
    end

    it "retorna erro para exceções ActiveRecord" do
      allow(ImportadorSigaa).to receive(:new).and_raise(ActiveRecord::RecordInvalid.new(Pessoa.new))

      post :importar, params: { file: temp_file }

      expect(response).to redirect_to(admin_gerenciamento_path)
      expect(flash[:alert]).to eq("Falha ao importar dados: dados do arquivo em formato inválido")
    end

    it "retorna erro para erro inesperado" do
      allow(ImportadorSigaa).to receive(:new).and_raise(StandardError.new("Erro inesperado"))

      expect(Rails.logger).to receive(:error).with(/\[IMPORT ERROR\] StandardError: Erro inesperado/)

      post :importar, params: { file: temp_file }

      expect(response).to redirect_to(admin_gerenciamento_path)
      expect(flash[:alert]).to eq("Falha ao importar dados: erro inesperado")
    end
  end
end