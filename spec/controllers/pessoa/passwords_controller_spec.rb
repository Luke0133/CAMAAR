require 'rails_helper'

RSpec.describe Pessoas::PasswordsController, type: :controller do
  include Devise::Test::ControllerHelpers
  render_views

  let(:pessoa) { create(:pessoa, email: "teste@example.com", password: nil) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:pessoa]
    session[:email] = nil
  end

  describe "GET #assert_reset_token_passed" do
    controller do
      def fake_action
        return if assert_reset_token_passed
        render plain: "OK"
      end
    end

    before { routes.draw { get "fake_action" => "pessoas/passwords#fake_action" } }

    it "quando não recebe token, redireciona para login e exibe alerta" do
      get :fake_action, params: {}
      expect(flash[:alert]).to eq("Token de redefinição de senha é inválido")
      expect(response).to redirect_to(new_pessoa_session_path)
    end

    it "quando recebe token, não redireciona nem define flash" do
      get :fake_action, params: { reset_password_token: "abc123" }
      expect(flash[:alert]).to be_nil
      expect(response.body).to eq("OK")
    end
  end

  describe "PUT #update" do
    let(:token) { pessoa.send_reset_password_instructions }

    it "com token e senhas válidas, reseta a senha, loga e redireciona com flash" do
      put :update, params: {
        pessoa: {
          reset_password_token: token,
          password: "nova_senha123",
          password_confirmation: "nova_senha123"
        }
      }

      pessoa.reload
      expect(pessoa.valid_password?("nova_senha123")).to be true
      expect(flash[:notice]).to eq("Senha redefinida com sucesso!")
      expect(session[:email]).to eq(pessoa.email)
      expect(response).to redirect_to(user_avaliacoes_path)
    end

    it "com token inválido, não reseta a senha e mostra alerta" do
      put :update, params: {
        pessoa: {
          reset_password_token: "token_invalido",
          password: "senha123",
          password_confirmation: "senha123"
        }
      }

      expect(flash[:alert]).to eq("Token de redefinição de senha é inválido")
    end
  end
end
