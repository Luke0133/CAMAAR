require 'rails_helper'

RSpec.describe User::AvaliacoesController, type: :controller do
  describe "GET #index" do
    # Usando factories, cria alunos, turmas e formulários para o teste
    let(:aluno) { create(:pessoa, email: "aluno@example.com") }
    let(:turmas) { create_list(:turma, 2) }
    let!(:formularios_validos) do
      turmas.map { |turma| create(:formulario, turma: turma, nome: "Formulário Válido") }
    end
    let!(:formularios_invalidos) do
      create_list(:formulario, 1, nome: "")
    end

    before do
      aluno.turmas << turmas
      session[:email] = aluno.email # 'loga' forçado o aluno teste
    end

    # Checar se email da sessão está correto
    it "finds aluno by session email" do
      expect(Pessoa).to receive(:find_by).with(email: aluno.email).and_call_original
      get :index
    end

    # Checar se recebeu id correto da turma
    it "gets turma ids from aluno" do
      get :index
      expect(assigns(:formularios).map(&:turma_id).uniq.sort).to eq(turmas.map(&:id).sort)
    end

    # Checar se formularios retornados realmente não foram recebidos, criando um formulário respondido 
    it "gets formularios not yet responded to by aluno" do
      responded_form = create(:formulario)
      aluno.formulario_respondidos.create!(formulario: responded_form)

      get :index
      expect(assigns(:formularios)).not_to include(responded_form)
    end

    # Checa se está retornando os formulários válidos
    it "returns valid formularios not yet responded to" do
      get :index
      expect(assigns(:formularios)).to match_array(formularios_validos)
    end

    # e acusando os formulários inválidos
    it "sets flash alert if there are invalid formularios" do
      get :index
      expect(flash.now[:alert]).to eq("Um ou mais formulários estão incompatíveis e não podem ser visualizados")
    end

    # Checa se não acusa inválidos caso não existam
    context "when no invalid forms exist" do
      before do
        # Para esse caso, torna o formulário inválido válido
        Formulario.where(nome: "").update_all(nome: "Valid")
      end

      it "does not set flash alert" do
        get :index
        expect(flash.now[:alert]).to be_nil
      end
    end

    # Checa se chama a view corretamente
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end
end