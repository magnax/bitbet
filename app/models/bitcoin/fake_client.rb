module Bitcoin
  class ConnectionError < StandardError; end

  class FakeClient
    def initialize
      @working = true
    end

    def working?
      @working
    end

    def set_response_for(method_name, response)
      instance_variable_set("@#{method_name}_response", response)
    end

    def create_user_account(_user)
      raise_error
      @create_user_account_response || true
    end

    def disable
      @working = false
    end

    def getnewaddress
      raise_error
      @getnewaddress_response || "abcde"
    end

    def listaccounts
      raise_error
      @listaccounts_response || []
    end

    def listtransactions(_user_id, _count, from)
      raise_error
      @listtransactions_response[from] || []
    end

    def setaccount(*_args)
      raise_error
      @setaccount_response || true
    end

    def validateaddress(_nr)
      raise_error
      @validateaddress_response || { 'isvalid' => true }
    end

    private

    def raise_error
      raise Bitcoin::ConnectionError, 'Bitcoin client not working!' unless working?
    end
  end
end
