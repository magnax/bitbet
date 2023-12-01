# frozen_string_literal: true

module Bitcoin
  class Client
    def initialize
      @service = RPC::JSON::Client.new "http://#{JSON_RPC_CLIENT['user']}:#{JSON_RPC_CLIENT['password']}@#{JSON_RPC_CLIENT['host']}:#{JSON_RPC_CLIENT['port']}",
                                       JSON_RPC_CLIENT['version']
    rescue SystemCallError
      @service = nil
    end

    def working?
      @service.present?
    end

    def method_missing(method_name, *arguments)
      raise ConnectionError unless working?

      begin
        @service.send(method_name.to_s, *arguments)
      rescue SystemCallError
        raise ConnectionError
      end
    end

    def create_user_account(user)
      account = user.build_account({
                                     account_type: 'deposit',
                                     nr: getnewaddress
                                   })
      return false unless account.save

      setaccount(account.nr, "user_#{user.id}")
      true
    end
  end
end
