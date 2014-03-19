class AdminController < ApplicationController
before_action :admin_user

def menu
end

def info
	begin
		@address = bitcoin_client.getinfo
	rescue BitcoinClient::ConnectionError
		redirect_with_error I18n.t 'flash.error.client_error'
	end
end

def transactions
	@output = ["start"]
	@accounts = bitcoin_client.listaccounts
	@accounts.each do |account, balance|
		if account.include?('user_')
			@output.push "account: #{account}"
			next_transaction = true
			i = 0
			user_id = account.gsub('user_', '').to_i
			last_transaction = Operation.deposits.where(:user_id => user_id).first
			last_transaction_txid = last_transaction.nil? ? nil : last_transaction.txid
			while next_transaction do
				transaction = bitcoin_client.listtransactions(account, 1, i)[0]
				if transaction.nil? || transaction['txid'] == last_transaction_txid
					next_transaction = false
					if transaction.nil?
						@output.push "-- end of transactions for #{account} --"
					else
						@output.push "-- existing transaction met --"
					end
				else
					@output.push " -> category: #{transaction['category']}"
					if transaction['category'] == 'receive'
						if transaction['confirmations'] > 2
							operation = Operation.new(
								:user_id => user_id,
								:amount => (BigDecimal(transaction['amount'].to_s) * 100000000.0).to_i,
								:account_id => nil,
								:bet_id => nil,
								:operation_type => 'receive',
								:txid => transaction['txid'],
								:time => transaction['time'],
								:timereceived => transaction['timereceived']
							)
							operation.save
							@output.push "deposited #{transaction['amount']} for user: #{user_id}"
						else
							@output.push "not enough confirmations (#{transaction['confirmations']} of 3) for #{transaction['amount']} BTC"
						end
					end
				end
				i += 1
			end
		else
			@output.push "skipping account: '#{account}'"
		end
	end
	@output.push "----"
	@output.push "end"
end

def account_fix
	user = User.find(params[:id])
	bitcoin_client.setaccount(user.deposit_address, "user_#{user.id}")
	redirect_to user
end

end
