require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    subject { get :index }

    context "quando o usuário é admin (funcao 0)" do
      let(:pessoa) { create(:pessoa, :admin) }
      
      before do
        session[:email] = pessoa.email
      end

      it "redireciona para admin_gerenciamento_path" do
        subject
        expect(response).to redirect_to(admin_gerenciamento_path)
      end
    end

    context "quando o usuário é professor (funcao 2)" do
      let(:pessoa) { create(:pessoa, :professor) }
      
      before do
        session[:email] = pessoa.email
      end

      it "redireciona para user_avaliacoes_path" do
        subject
        expect(response).to redirect_to(user_avaliacoes_path)
      end
    end

    context "quando o usuário é aluno (funcao 1)" do
      let(:pessoa) { create(:pessoa, :aluno) }
      
      before do
        session[:email] = pessoa.email
      end

      it "redireciona para user_avaliacoes_path" do
        subject
        expect(response).to redirect_to(user_avaliacoes_path)
      end
    end

    context "quando o usuário possui múltiplos cargos (admin e professor)" do
      let(:pessoa) { create(:pessoa, :admin_professor) }
      
      before do
        session[:email] = pessoa.email
      end

      it "prioriza admin e redireciona para admin_gerenciamento_path" do
        subject
        expect(response).to redirect_to(admin_gerenciamento_path)
      end
    end

    context "quando o usuário não possui cargos válidos" do
      let(:pessoa) { create(:pessoa) } # sem cargos
      
      before do
        session[:email] = pessoa.email
      end

      it "redireciona para root_path com alerta" do
        subject
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Você não tem permissão de acesso.")
      end
    end
  end
end