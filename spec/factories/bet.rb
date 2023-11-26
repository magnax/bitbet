FactoryGirl.define do
  factory :bet do
    sequence(:name)  { |n| "Some bet name #{n}" }
    sequence(:text) { |n| "This is the description of bet number #{n}" }
    user
    category
    event_at Date.today + 20
    deadline Date.today + 17
    positive 1

    factory :banned do
      banned true
    end

    factory :published_bet do
      published_at DateTime.now
    end
  end
end