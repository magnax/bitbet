class UsersController < ApplicationController
  before_action :signed_in_user, only: [ :show ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = I18n.t 'flash.success.user_created'
      try_create_bitcoin_account(@user)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def show
    @user = current_user
  end

  def name_availability
    render :text => ((User.find_by_name(params[:name])) ? "this name is not available" : "OK!")
  end

private
  
  def try_create_bitcoin_account(user)
    begin
      unless bitcoin_client.create_user_account(user)
        flash[:notice] = I18n.t 'flash.notice.user_account_failed'
      end
    rescue Bitcoin::ConnectionError
      flash[:error] = I18n.t 'flash.error.client_error'
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :ref_id)
  end
end
