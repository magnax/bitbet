class User < ActiveRecord::Base
include BitcoinHelper

before_save { self.email = email.downcase }
before_create :create_remember_token

validates :name, presence: true, length: { maximum: 50 }
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
			uniqueness: { case_sensitive: false }

has_secure_password
validates :password, length: { minimum: 6 }

#bets created by user
has_many :bets

has_many :bids

#bets in which user participating
has_many :bidded_bets, through: :bids, source: :bet

has_many :accounts

has_many :operations

def User.new_remember_token
	SecureRandom.urlsafe_base64
end

def User.encrypt(token)
	Digest::SHA1.hexdigest(token.to_s)
end

def available_funds
	operations.incomings.sum(:amount) - frozen_funds
end

def frozen_funds
	bidded_bets.visible.sum('bids.amount')
end

def deposit_address
	accounts.deposit.any? ? accounts.deposit.first.nr : nil
end

def withdrawal_address
	accounts.withdraw.any? ? accounts.withdraw.first.nr : nil
end

def bc_account
	bc.getaccount(deposit_address)
end

def referrals
	[]
end

def created_bets
	bets.created
end

def active_bets
	bets.active
end

def waiting_bets
	bets.waiting
end

def closed_bets
	[]
end

def rejected_bets
	[]
end

def active_bids
	bidded_bets.visible.group(:bet_id)
end

def closed_bids
	bidded_bets.closed.group(:bet_id)
end

def deposits
	operations.incomings
end

def withdrawals
	[]
end

private

def create_remember_token
	self.remember_token = User.encrypt(User.new_remember_token)
end

end
