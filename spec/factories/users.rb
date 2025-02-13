FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email }
    password { "Password@123" }
    mobile_number { "+91-#{Faker::Number.number(digits: 10)}" } # Generates a unique 10-digit number
  end
end
