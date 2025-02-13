FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }
    password { "Password@123" }
    mobile_number { "+91-9876543210" }
  end
end
