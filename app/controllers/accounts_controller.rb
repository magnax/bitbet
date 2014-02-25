class AccountsController < ApplicationController
before_action :signed_in_user
before_action :bitcoin_client, only: [ :create ]

def new
  @account = Account.new(:user => current_user)
end

def create
	@account = current_user.build_account(account_params.merge({ account_type: 'withdraw' }))
	if @account.save
		redirect_to profile_path, notice: "Zmieniono adres do wypłat"
	else
		render :template => 'users/withdrawal_address'
	end
end

def create_deposit_address
  account = current_user.build_account({
    :account_type => "deposit",
    :nr => bc.getnewaddress
  })
  if account.save
    bc.setaccount(account.nr, "user_#{current_user.id}")
    flash[:success] = "Pomyślnie przydzielono nowy adres depozytowy!" 
  else
    flash[:error] = "Nie udało się przydzielić nowego adresu!" 
  end
  redirect_to profile_path
end

private

def account_params
	params.require(:account).permit(:user_id, :nr) 
end

end
