class OperationsController < ApplicationController
before_action :bitcoin_client, only: [:create]

def create
	begin
		@operation = current_user.operations.withdraws.build(operations_params)
		if @operation.valid?
			txid = bc.sendfrom(
				"user_#{current_user.id}", 
				current_user.withdrawal_address, 
				@operation.amount_in_stc
			)
			@operation.operation_type = "send"
			@operation.txid = txid
			@operation.time = @operation.timereceived = DateTime.now
			if @operation.save
				redirect_to profile_path, flash: {success: "Wypłaciłeś pomyślnie kwotę #{@operation.amount_in_stc.to_s.gsub('.', ',')} BTC!"} and return
			end		
		end
	rescue RPC::JSON::Client::Error => e
		flash.now[:error] = "Operacja wypłaty nie powiodła się"
	end
	render 'withdraw'
end

def withdraw
	@operation = current_user.operations.withdraws.new
end

private

	def operations_params
		params.require(:operation).permit(:user_id, :amount_in_stc) 
	end
end
