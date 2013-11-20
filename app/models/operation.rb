#encoding = utf-8
class Operation < ActiveRecord::Base

default_scope  lambda { order('operations.created_at DESC') }
scope :deposits, lambda { where('operations.operation_type = ?', 'receive') }
scope :winnings, lambda { where('operations.operation_type = ?', 'prize') }
scope :incomings, lambda { where('operations.operation_type in (?)', ['receive', 'prize']) }
scope :withdraws, lambda { where('operations.operation_type = ?', 'send') }
scope :losings, lambda { where('operations.operation_type = ?', 'loss') }
scope :outcomings, lambda { where('operations.operation_type in (?)', ['send', 'loss']) }

def Operation.check_deposits
	puts "666 new deposits"
end

def Operation.types
	{ 
		'receive' => 'Wpłata', 
		'waiting'  => 'oczekujące',
		'visible' => 'widoczne',
		'closed' => 'zakończone',
	} 
end

end
