# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    user
    nr { 'aaaaaabbbbbbccccccddddddeeeeeeffffff' }
    account_type { 'deposit' }
  end
end
