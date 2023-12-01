FactoryBot.define do
  factory :fee do
    amount_in_stc { 0.1 }
    bet
    notes { 'new bet fee' }
  end
end
