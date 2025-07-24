require 'rails_helper'

RSpec.describe Admin::FormulariosController, type: :controller do
  render_views

  let(:admin) { create(:pessoa, email: "admin@camaar.com") }

  before do
    session[:email] = admin.email
  end
  
  it "atribui um novo formulário e carrega dados do formulário" do
    template = create(:template)
    materia = create(:materia)
    turma = create(:turma, materia: materia)

    get :new

    expect(response).to render_template(:new)
    expect(assigns(:formulario)).to be_a_new(Formulario)
    expect(assigns(:templates)).to include(template)
    expect(assigns(:materias)).to include(materia)
    expect(assigns(:turmas_por_materia)[materia]).to eq(turma)
  end

  describe "POST #create" do
    context "com dados válidos" do
      it "cria um formulário e redireciona" do
        materia = create(:materia)
        turma = create(:turma, materia: materia)

        ligacao = create(:ligacao_pergunta)
        create(:pergunta, ligacao_pergunta: ligacao)
        template = create(:template, ligacao_pergunta: ligacao)

        expect {
          post :create, params: {
            formulario: {
              template_id: template.id,
              materia_ids: [materia.id]
            }
          }
        }.to change(Formulario, :count).by(1)

        expect(response).to redirect_to(admin_gerenciamento_path)
        expect(flash[:notice]).to eq("Formulário enviado com sucesso")
      end
    end

    context "sem template selecionado" do
      it "não cria formulário e renderiza :new com erro" do
        materia = create(:materia)
        create(:turma, materia: materia)

        post :create, params: {
          formulario: {
            template_id: nil,
            materia_ids: [materia.id]
          }
        }

        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("Nenhum template selecionado")
      end
    end

    context "sem matéria selecionada" do
      it "não cria formulário e renderiza :new com erro" do
        ligacao = create(:ligacao_pergunta)
        create(:pergunta, ligacao_pergunta: ligacao)
        template = create(:template, ligacao_pergunta: ligacao)

        post :create, params: {
          formulario: {
            template_id: template.id,
            materia_ids: []
          }
        }

        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("Nenhuma matéria foi selecionada")
      end
    end

    context "quando a matéria não possui turma" do
      it "não cria formulário e renderiza :new com alerta de turma" do
        materia = create(:materia)

        ligacao = create(:ligacao_pergunta)
        create(:pergunta, ligacao_pergunta: ligacao)
        template = create(:template, ligacao_pergunta: ligacao)

        post :create, params: {
          formulario: {
            template_id: template.id,
            materia_ids: [materia.id]
          }
        }

        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("A matéria #{materia.nome} não possui turmas")
      end
    end

    context "quando o formulário não é salvo por erro inesperado" do
      it "não cria formulário e renderiza :new com alerta genérico" do
        materia = create(:materia)
        turma = create(:turma, materia: materia)

        ligacao = create(:ligacao_pergunta)
        create(:pergunta, ligacao_pergunta: ligacao)
        template = create(:template, ligacao_pergunta: ligacao)

        # Simula erro de validação no formulário
        allow_any_instance_of(Formulario).to receive(:save).and_return(false)

        expect {
          post :create, params: {
            formulario: {
              template_id: template.id,
              materia_ids: [materia.id]
            }
          }
        }.not_to change(Formulario, :count)

        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("Erro ao salvar os formulários")
      end
    end

    context "com destino definido como 'aluno'" do
      it "cria formulário com destino 1" do
        materia = create(:materia)
        turma = create(:turma, materia: materia)

        ligacao = create(:ligacao_pergunta)
        create(:pergunta, ligacao_pergunta: ligacao)
        template = create(:template, ligacao_pergunta: ligacao)

        post :create, params: {
          formulario: {
            template_id: template.id,
            materia_ids: [materia.id],
            destino: "aluno"
          }
        }

        formulario = Formulario.last
        expect(formulario.destino).to eq(1)
      end
    end

    context "com destino definido como 'professor'" do
      it "cria formulário com destino 2" do
        materia = create(:materia)
        turma = create(:turma, materia: materia)

        ligacao = create(:ligacao_pergunta)
        create(:pergunta, ligacao_pergunta: ligacao)
        template = create(:template, ligacao_pergunta: ligacao)

        post :create, params: {
          formulario: {
            template_id: template.id,
            materia_ids: [materia.id],
            destino: "professor"
          }
        }

        formulario = Formulario.last
        expect(formulario.destino).to eq(2)
      end
    end

    context "com destino inválido ou ausente" do
      it "usa destino padrão 3 (todos)" do
        materia = create(:materia)
        turma = create(:turma, materia: materia)

        ligacao = create(:ligacao_pergunta)
        create(:pergunta, ligacao_pergunta: ligacao)
        template = create(:template, ligacao_pergunta: ligacao)

        post :create, params: {
          formulario: {
            template_id: template.id,
            materia_ids: [materia.id],
            destino: "todos"
          }
        }

        formulario = Formulario.last
        expect(formulario.destino).to eq(3)
      end
    end
  end
end