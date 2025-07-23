require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  # Caminho falso para os testes
  controller do
    def index
      render plain: "Hello"
    end
  end

  context "quando usuário não está logado" do
    it "redireciona para página de login" do
      get :index
      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("Você precisa estar logado para acessar esta página.")
    end
  end

  context "quando logado" do
    let(:aluno) { create(:pessoa, email: "aluno@example.com") }

    before do
      session[:email] = aluno.email # 'loga' forçado o aluno teste
    end

    it "permite entrar na página" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("Hello")
    end
  end
end