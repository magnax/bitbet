FactoryBot.define do
  sequence(:name) { |n| "user_#{n}" }
  sequence(:email)  { |n| "user#{n}@mail.com" }

  factory :user do
    name
    email
    password { "111111" }
    password_confirmation { "111111" }

    trait :admin do
      admin {true}
    end
  end
end
