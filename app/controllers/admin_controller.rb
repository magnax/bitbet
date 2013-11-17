class AdminController < ApplicationController
before_action :admin_user
before_action :bitcoin_client, only: [ :info ]

def menu
end

def info
	@address = bc.getinfo
end

end
