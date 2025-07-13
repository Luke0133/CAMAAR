FactoryBot.define do
  factory :formulario do
    nome { "Formulário 1" }
    association :turma
    association :ligacao_pergunta
  end
end