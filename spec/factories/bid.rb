FactoryBot.define do
  factory :bid do
    user
    bet
    amount_in_stc { 2 }
    positive { 1 }
  end
end
