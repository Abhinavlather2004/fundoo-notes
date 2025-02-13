FactoryBot.define do
  factory :collaboration do
    association :user
    association :note
  end
end
