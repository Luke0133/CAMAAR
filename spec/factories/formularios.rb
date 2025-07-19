FactoryBot.define do
  factory :formulario do
    nome { "Formulário #{SecureRandom.hex(2)}" }
    association :turma
    association :ligacao_pergunta

    trait :com_perguntas do
      after(:create) do |formulario|
        create(:pergunta, ligacao_pergunta: formulario.ligacao_pergunta)
        create(:pergunta, :radio, ligacao_pergunta: formulario.ligacao_pergunta)
      end
    end

    trait :invalido do
      nome { "" }
    end
  end
end