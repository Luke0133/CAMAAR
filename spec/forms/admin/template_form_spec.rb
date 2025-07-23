require 'rails_helper'

RSpec.describe Admin::TemplateForm, type: :model do
  describe '#save' do
    let(:valid_questions) do
      [
        {
          text: 'Qual a cor?',
          type: '0',
          options: ['Azul', 'Vermelho']
        },
        {
          text: 'Qual seu nome?',
          type: '1'
        }
      ]
    end

    context 'com dados válidos' do
      it 'cria um novo template e perguntas' do
        form = described_class.new(nome: 'Teste', questions: valid_questions)

        expect(form.save).to be true
        expect(form.template).to be_persisted
        expect(form.template.nome).to eq('Teste')
        expect(form.template.ligacao_pergunta.perguntas.count).to eq(2)
      end
    end

    context 'com nome ausente' do
      it 'retorna erro de validação' do
        form = described_class.new(nome: '', questions: valid_questions)

        expect(form.save).to be false
        expect(form.errors[:nome]).to include("O nome do template não pode estar em branco")
      end
    end

    context 'com pergunta sem texto' do
      it 'retorna erro customizado' do
        invalid_questions = [{ text: '', type: '1' }]
        form = described_class.new(nome: 'Teste', questions: invalid_questions)

        expect(form.save).to be false
        expect(form.errors[:questions]).to include("Deve haver pelo menos uma pergunta e todas devem ter texto")
      end
    end

    context 'com opções em branco' do
      it 'retorna erro de opções' do
        invalid_questions = [{ text: 'Pergunta', type: '0', options: ['Opção 1', ''] }]
        form = described_class.new(nome: 'Teste', questions: invalid_questions)

        expect(form.save).to be false
        expect(form.errors[:options]).to include("Todas as opções de todas as perguntas devem estar preenchidas")
      end
    end

    context 'quando há RecordInvalid ao salvar pergunta' do
      it 'resgata e adiciona erros ao form' do
        allow(Pergunta).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Pergunta.new.tap do |p|
          p.errors.add(:pergunta, "não pode estar em branco")
        end))

        form = described_class.new(nome: 'Teste', questions: valid_questions)
        expect(form.save).to be false
        expect(form.errors[:pergunta]).to include("não pode estar em branco")
      end
    end
  end
end
