FactoryBot.define do
  factory :template do
    sequence(:nome) { |n| "Template #{n}" }
    association :ligacao_pergunta
  end
end
