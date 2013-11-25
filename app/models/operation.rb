#encoding = utf-8
class Operation < ActiveRecord::Base
include BitcoinHelper
include CheckUser

validates :amount_in_stc, presence: true, exclusion: { in: [0] }
validate :available_funds

belongs_to :user
belongs_to :bet

default_scope  lambda { order('operations.created_at DESC') }
scope :deposits, lambda { where('operations.operation_type = ?', 'receive') }
scope :winnings, lambda { where('operations.operation_type = ?', 'prize') }
scope :incomings, lambda { where('operations.operation_type in (?)', ['receive', 'prize']) }
scope :withdraws, lambda { where('operations.operation_type = ?', 'send') }
scope :losings, lambda { where('operations.operation_type = ?', 'loss') }
scope :outgoings, lambda { where('operations.operation_type in (?)', ['send', 'loss']) }
scope :commissions, lambda { where('operations.operation_type = ?', 'commission') }

def Operation.check_deposits
	puts "666 new deposits"
end

def Operation.types
	{ 
		'receive' => 'Wpłata', 
		'send'  => 'Wypłata z konta',
		'prize' => 'Wygrana',
		'loss' => 'Przegrana',
		'commission' => 'Prowizja'
	} 
end

end
