FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.cell_phone }
    full_name { Faker::Name.name }
    password { "password" }
    password_confirmation { "password" }
    account_key { "ABCDEF" }
    metadata { "male, age 32, unemployed, college-educated" }
  end
end
