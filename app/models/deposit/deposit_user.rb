module Deposit
  class DepositUser
    def initialize(user_id)
      @user = User.find(user_id)
    end

    def get_last_deposit_id
      @user.get_last_deposit_id 
    end

    def create_new_deposit(transaction)
      @user.create_new_deposit(transaction)
    end
  end
end