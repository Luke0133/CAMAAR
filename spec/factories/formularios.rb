FactoryBot.define do
  factory :formulario do
    nome { "Formulário 1" }
    association :turma
    association :ligacao_pergunta

    trait :com_respostas do
      after(:create) do |formulario|
        pergunta = create(:pergunta, ligacao_pergunta: formulario.ligacao_pergunta)
        create(:resposta, formulario: formulario, pergunta: pergunta, conteudo: "Resposta teste")
      end
    end

    trait :sem_respostas do
    end
  end
end