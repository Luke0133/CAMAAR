require 'rails_helper'

RSpec.describe Admin::GerenciamentoController, type: :controller do
  render_views

  let(:admin) { create(:pessoa, :admin, email: "admin@camaar.com") }

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

    it "importa com sucesso e exibe mensagem" do
      importador = instance_double(ImportadorSigaa)
      allow(ImportadorSigaa).to receive(:new).and_return(importador)
      allow(importador).to receive(:processar)

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

  # Testa método de redefinir senha
  describe "POST #redefinir_senha" do
    before do
      ActionMailer::Base.deliveries.clear
    end

      it "redireciona corretamente com mensagem de sucesso" do
        allow(controller).to receive(:redirect_back)
        expect(controller).to receive(:redirect_back).with(
          fallback_location: admin_gerenciamento_path,
          notice: "Email de redefinição de senha enviado com sucesso!"
        )
        
        post :redefinir_senha
      end

    context "quando não há admin logado" do
      before do
        session[:email] = nil
      end

      it "exige autenticação do admin" do
        post :redefinir_senha
        expect(response).to redirect_to(login_path)
        expect(flash[:error]).to eq("Você precisa estar logado para acessar esta página.")
      end
    end
  end

  # Testa método privado enviar_email_redefinicao
  describe "#enviar_email_redefinicao" do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it "gera token de redefinição de senha" do
      expect(Devise.token_generator).to receive(:generate).with(Pessoa, :reset_password_token).and_call_original
      
      controller.send(:enviar_email_redefinicao, admin)
    end

    it "atualiza admin com token e timestamp" do
      controller.send(:enviar_email_redefinicao, admin)
      
      admin.reload
      expect(admin.reset_password_token).not_to be_nil
      expect(admin.reset_password_sent_at).not_to be_nil
      expect(admin.reset_password_sent_at).to be_within(1.minute).of(Time.current)
    end

    it "envia email de redefinição de senha" do
      expect {
        controller.send(:enviar_email_redefinicao, admin)
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
      
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include(admin.email)
      expect(mail.subject).to match(/Definição de Senha - CAMAAR/i)
    end

    it "loga detalhes do email" do
      log_file = instance_double("File")
      expect(File).to receive(:open).with(
        Rails.root.join("log", "emails_enviados.log"), "a"
      ).and_yield(log_file)
      
      expect(log_file).to receive(:puts).with(
        a_string_matching(/\[\d{4}-\d{2}-\d{2}.*\] Redefinição solicitada para #{admin.email}/)
      )
      
      controller.send(:enviar_email_redefinicao, admin)
    end
  end
end