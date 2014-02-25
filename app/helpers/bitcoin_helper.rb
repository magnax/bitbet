module BitcoinHelper

def bitcoin_client
	begin
		@bc = RPC::JSON::Client.new "http://#{json_rpc_client.user}:#{json_rpc_client.password}@#{json_rpc_client.host}:#{json_rpc_client.port}", json_rpc_client.version
	rescue SystemCallError
		redirect_to root_path, :flash => { :error => "Client not working" }
	end
	@bc
end

def bc
	@bc ||= bitcoin_client
end

def amount_in_stc=(value)
	s = value.to_s.gsub(',', '.')
	if s.to_i.to_s == s || s.to_f.to_s == s || s.to_f.to_s == "0" + s
		self.amount = (BigDecimal(s) * 100000000.0).to_i
	else
		self.amount = 0
	end
end

def amount_in_stc
 	amount / 100000000.0 unless amount.nil?
end

end