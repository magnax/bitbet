FactoryGirl.define do
  factory :operation do
    user
    amount_in_stc 1
    account
    bet
    operation_type 'deposit'
    txid nil
    time nil
    timereceived nil
  end
end