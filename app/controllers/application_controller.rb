class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include ApplicationHelper
  include SessionsHelper
  include BitcoinHelper

  private

  def valid_bitcoin_client
    render 'errors/error' unless bitcoin_client.working?
  end

  def bitcoin_client
    Bitcoin::Client.new
  end
end
