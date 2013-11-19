class SessionsController < ApplicationController

def new
end

def create
  	user = User.find_by(name: params[:session][:name])
    if user && user.authenticate(params[:session][:password])
		sign_in user
		redirect_back_or profile_path
    else
		flash.now[:error] = 'Invalid email/password combination' # Not quite right!
		render 'new'
    end
end

def destroy
	sign_out
	redirect_to root_url
end 

end