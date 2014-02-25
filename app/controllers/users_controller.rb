#encoding = utf-8
class UsersController < ApplicationController
before_action :signed_in_user, only: [ :show, :withdrawal_address ]
before_action :bitcoin_client, only: [ :withdrawal_address, :deposit_address ]

def new
	@user = User.new
end

def create
	@user = User.new(user_params)
	if @user.save
		sign_in @user
		flash[:success] = "Twoje konto użytkownika zostało utworzone. Jesteś zalogowany"
		redirect_to root_path
	else
		render 'new'
	end
end

def show
	@user = current_user
end

private

def user_params
	params.require(:user).permit(:name, :email, :password, :password_confirmation, :ref_id) 
end

end
