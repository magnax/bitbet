FactoryBot.define do
  factory :operation do
    user
    amount_in_stc { 1 }
    account
    bet { nil }
    operation_type { 'receive' }
    txid { nil }
    time { nil }
    timereceived { nil }
  end
end
