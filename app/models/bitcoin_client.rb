#require 'rpcjson'

class BitcoinClient
  class ConnectionError < StandardError; end

  def initialize
    begin
      @service = RPC::JSON::Client.new "http://#{JSON_RPC_CLIENT['user']}:#{JSON_RPC_CLIENT['password']}@#{JSON_RPC_CLIENT['host']}:#{JSON_RPC_CLIENT['port']}", JSON_RPC_CLIENT['version']
    rescue SystemCallError
    #  @service = nil
    end
  end

  def method_missing(method_name, *arguments)
    raise ConnectionError unless @service
    begin
      @service.send(method_name.to_s, *arguments)
    rescue SystemCallError
      raise ConnectionError
    end
  end

  def create_user_account(user)
    account = user.build_account({
      :account_type => "deposit",
      :nr => self.getnewaddress
    })
    return false unless account.save
    self.setaccount(account.nr, "user_#{user.id}")
    true
  end
end