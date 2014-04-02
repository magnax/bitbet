module Bitcoin
  class FakeClient
    
    def initialize(not_working = false)
      @not_working = not_working
    end

    def listaccounts
      raise BitcoinClient::ConnectionError if @not_working
      []
    end
  end
end
