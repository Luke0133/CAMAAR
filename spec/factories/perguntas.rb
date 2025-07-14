FactoryBot.define do
  factory :pergunta do
    ligacao_pergunta
    tipo { 1 }   # 0=radio, 1=text
    pergunta { "Qual a sua opinião?" }
  end
end