require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  
  describe "#require_login" do
  # Caminho falso para os testes de login
    controller do
      def index
        render plain: "Hello"
      end
    end

    context "quando usuário não está logado" do
      it "redireciona para página de login" do
        get :index
        expect(response).to redirect_to(login_path)
        expect(flash[:error]).to eq("Você precisa estar logado para acessar esta página.")
      end
    end

    context "quando logado" do
      let(:aluno) { create(:pessoa, :aluno, email: "aluno@example.com") }
      
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

  describe "#authorize_admin!" do
  # Caminho falso para os testes de ser ou não admin
    controller do
      before_action :authorize_admin!

      def index
        render plain: "Hello"
      end
    end

    context "quando usuario não é admin" do
      let(:aluno) { create(:pessoa, :aluno, email: "aluno@example.com") }
      
      before do
        session[:email] = aluno.email # 'loga' forçado o aluno teste
        get :index
      end

      it "redireciona para o dashboard" do
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:error]).to eq("Você não tem permissão para acessar essa área administrativa.")
      end
    end

    context "quando é admin" do
      let(:admin) { create(:pessoa, :admin, email: "admin@example.com") }
      
      before do
        session[:email] = admin.email # 'loga' forçado o admin teste
        get :index
      end

      it "permite acessar" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("Hello")
      end
    end
  end

  describe "#authorize_usuario!" do
  # Caminho falso para os testes de ser ou não usuário
    controller do
      before_action :authorize_usuario!

      def index
        render plain: "Hello"
      end
    end

    context "quando pessoa não é usuário" do
      let(:admin) { create(:pessoa, :admin, email: "admin@example.com") }
      
      before do
        session[:email] = admin.email # 'loga' forçado o admin teste
        get :index
      end

      it "redireciona para o dashboard" do
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:error]).to eq("Você não tem permissão para acessar essa área de usuário.")
      end
    end

    context "quando é usuário" do
      let(:aluno) { create(:pessoa, :aluno, email: "aluno@example.com") }
      
      before do
        session[:email] = aluno.email # 'loga' forçado o aluno teste
        get :index
      end

      it "allows access" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("Hello")
      end
    end
  end
end