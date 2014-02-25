FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "user_#{n}" }
    sequence(:email)  { |n| "user#{n}@mail.com" }
    password "111111"
    password_confirmation "111111"

    factory :admin do
      admin true
    end
  end
end