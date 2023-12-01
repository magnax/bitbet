module Deposit
  class Check
    MIN_CONFIRMATIONS_REQUIRED = 3

    def initialize(service)
      @service = service
      @output = []
    end

    def check
      @output = ['start']
      @service.listaccounts.each do |account, _balance|
        process_account(account)
      end
      @output << 'end'
    end

    def process_account(account)
      if account.include?('user_')
        @output << "account: '#{account}'"
        process_transactions(account)
      else
        @output << "skip: '#{account}'"
      end
    end

    def process_transactions(account)
      process_next_transaction(account, 0, get_last_transaction_txid(account))
      @output << "-- end '#{account}'"
    end

    def get_last_transaction_txid(account)
      user = DepositUser.new account.gsub('user_', '').to_i
      user.get_last_deposit_id
    end

    def process_next_transaction(account, iteration, last_txid)
      transaction = @service.listtransactions(account, 1, iteration)[0]
      if transaction.nil?
        @output << end_or_no_transactions(iteration, account)
        nil
      else
        last_or_deposit(transaction, last_txid)
        process_next_transaction(account, iteration + 1, last_txid)
      end
    end

    def end_or_no_transactions(t_count, account)
      t_count.zero? ? "-- no transactions for '#{account}' --" : "-- end of transactions for '#{account}' --"
    end

    def last_or_deposit(transaction, last_txid)
      if transaction['txid'] == last_txid
        @output << '-- existing transaction met --'
      elsif transaction['category'] == 'receive'
        @output << deposit_or_no_confirmations(transaction)
      end
    end

    def deposit_or_no_confirmations(transaction)
      if transaction['confirmations'] < MIN_CONFIRMATIONS_REQUIRED
        @output << "-- not enough confirmations (#{transaction['confirmations']}/" \
                   "#{MIN_CONFIRMATIONS_REQUIRED}) for #{transaction['amount']} BTC --"
      else
        make_deposit(transaction)
      end
    end

    def make_deposit(transaction)
      user = DepositUser.new transaction['account'].gsub('user_', '').to_i
      user.create_new_deposit(transaction)
      @output << "-- deposited #{transaction['amount']} BTC for '#{transaction['account']}' --"
    end
  end
end
