#encoding = utf-8
class UsersController < ApplicationController
before_action :signed_in_user, only: [:show]
before_action :bitcoin_client, only: [ :withdrawal_address, :deposit_address ]

def new
	@user = User.new
end

def create
	@user = User.new(user_params)
	if @user.save
		redirect_to root_path
	else
		render 'new'
	end
end

def show
	@user = current_user
end

def withdrawal_address
	@account = Account.new(:user => current_user)
end

def deposit_address
	account = Account.new(:user => current_user)
	account.account_type = "deposit"
	account.nr = bc.getnewaddress
	if account.save
		flash[:success] = "Pomyślnie przydzielono nowy adres depozytowy!" 
	else
		flash[:error] = "Nie udało się przydzielić nowego adresu!" 
	end
	redirect_to profile_path
end

private

def user_params
	params.require(:user).permit(:name, :email, :password, :password_confirmation, :ref_id) 
end

end
