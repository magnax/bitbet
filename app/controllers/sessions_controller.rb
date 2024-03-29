# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(name: params[:session][:name])
    if user&.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user_path(user)
    else
      flash.now[:error] = I18n.t 'flash.error.login'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url, flash: { notice: I18n.t('flash.notice.logout') }
  end
end
