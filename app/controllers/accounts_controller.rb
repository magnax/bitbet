class AccountsController < ApplicationController
  before_action :signed_in_user

  def new
    @account = Account.new(:user => current_user)
  end

  def create
    @account = current_user.build_account(account_params.merge({ account_type: 'withdraw' }))
    if @account.save
      msg = I18n.t 'flash.notice.account_created'
      redirect_to profile_path, notice: msg
    else
      render 'new'
    end
  end

  def create_deposit_address
    begin
      account = current_user.build_account({
        :account_type => "deposit",
        :nr => bitcoin_client.getnewaddress
      })
      if account.save
        bitcoin_client.setaccount(account.nr, "user_#{current_user.id}")
        flash[:success] = I18n.t 'flash.success.deposit_address'
      else
        flash[:error] = I18n.t 'flash.error.deposit_address'
      end
    rescue BitcoinClient::ConnectionError
      redirect_with_error I18n.t 'flash.error.client_error' and return
    end
    redirect_to profile_path
  end

private

  def account_params
    params.require(:account).permit(:user_id, :nr)
  end
end
