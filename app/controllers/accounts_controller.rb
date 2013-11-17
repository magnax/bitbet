class AccountsController < ApplicationController

def create
	@account = current_user.accounts.build(account_params)
	@account.account_type = 'withdraw'
	if @account.save
		redirect_to profile_path, notice: "Zmieniono adres do wypłat"
	else
		render :template => 'users/withdrawal_address'
	end
end

private

  	def account_params
  		params.require(:account).permit(:user_id, :nr) 
  	end

end
