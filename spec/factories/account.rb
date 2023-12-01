FactoryBot.define do
  factory :account do
    user
    nr { 'aaaaaabbbbbbccccccddddddeeeeeeffffff' }
    account_type { 'deposit' }
  end
end
