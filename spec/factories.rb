FactoryGirl.define do

  factory :bet do
  	
    sequence(:name)  { |n| "Some bet name #{n}" }
    sequence(:text) { |n| "This is the description of bet number #{n}"}
    user_id 1
    category_id 1
    event_at "2013-12-31"
    deadline "2013-12-20"
    positive 1

    factory :banned do
      banned true
    end

    factory :published_bet do
      published_at "2013-11-11 13:54:11"
    end
    
  end

  factory :bid do
    user_id 1
    bet_id 1
    amount_in_stc 2
    positive 1
  end

  factory :user do
    sequence(:name) { |n| "user_#{n}" }
    sequence(:email)  { |n| "user#{n}@mail.com" }
    password "111111"
    password_confirmation "111111"

    factory :admin do
      admin true
    end

  end

  factory :operation do

  end

end