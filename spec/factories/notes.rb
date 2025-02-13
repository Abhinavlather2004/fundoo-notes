FactoryBot.define do
  factory :note do
    content { "This is a test note." }
    isDeleted { false }
    isArchive { false }
    color { "#FFFFFF" }
    association :user
  end
end
