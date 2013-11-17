class Account < ActiveRecord::Base
include BitcoinHelper

validates :nr, presence: true
validates_uniqueness_of :nr
validate :valid_bitcoin_address

belongs_to :user

default_scope lambda { order('accounts.created_at DESC') }
scope :deposit, lambda { where('accounts.account_type = ?', 'deposit') }
scope :withdraw, lambda { where('accounts.account_type = ?', 'withdraw') }

private

	def valid_bitcoin_address
		if !bc.validateaddress(nr)['isvalid']
			errors.add(:nr, :not_valid)
		end
	end

end
