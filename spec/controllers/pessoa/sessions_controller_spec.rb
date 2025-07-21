require 'rails_helper'

RSpec.describe Pessoas::SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers
  render_views

  let!(:pessoa) { create(:pessoa, email: "aluno@exemplo.com", password: "senha123", matricula: "2023123456") }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:pessoa]
  end

  describe "GET #new" do
    it "responde com sucesso e renderiza a tela de login" do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(assigns(:resource)).to be_a_new(Pessoa)
      expect(assigns(:resource_name)).to eq(:pessoa)
      expect(assigns(:devise_mapping)).to eq Devise.mappings[:pessoa]
    end
  end

  describe "POST #create" do
    context "com credenciais válidas (email + senha)" do
      it "autentica o usuário e redireciona para a página inicial" do
        post :create, params: {
          pessoa: {
            login: pessoa.email,
            password: "senha123"
          }
        }

        expect(controller.current_pessoa).to eq(pessoa)
        expect(session[:email]).to eq(pessoa.email)
        expect(flash[:notice]).to eq("Login efetuado com sucesso")
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "com credenciais válidas (matrícula + senha)" do
      it "autentica o usuário via matrícula e redireciona corretamente" do
        post :create, params: {
          pessoa: {
            login: pessoa.matricula,
            password: "senha123"
          }
        }

        expect(controller.current_pessoa).to eq(pessoa)
        expect(session[:email]).to eq(pessoa.email)
        expect(flash[:notice]).to eq("Login efetuado com sucesso")
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "com credenciais inválidas" do
      it "não autentica e exibe mensagem de erro" do
        post :create, params: {
          pessoa: {
            login: "email_incorreto@exemplo.com",
            password: "senha_errada"
          }
        }

        expect(controller.current_pessoa).to be_nil
        expect(assigns(:resource)).to be_a(Pessoa)
        expect(flash.now[:alert]).to eq("Login ou senha inválidos")
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
