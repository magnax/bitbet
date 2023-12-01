# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :signed_in_user
  before_action :admin_user

  def menu; end

  def info
    @address = bitcoin_client.getinfo
  rescue Bitcoin::ConnectionError
    redirect_with_error I18n.t 'flash.error.client_error'
  end

  def transactions
    deposit_check = Deposit::Check.new(bitcoin_client)
    begin
      @output = deposit_check.check
    rescue Bitcoin::ConnectionError
      redirect_with_error I18n.t 'flash.error.client_error' and return
    end
  end

  def account_fix
    user = User.find(params[:id])
    bitcoin_client.setaccount(user.deposit_address, "user_#{user.id}")
    redirect_to user
  end
end
