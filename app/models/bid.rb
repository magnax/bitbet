class Bid < ActiveRecord::Base

validates :user_id, presence: true	
validates :bet_id, presence: true
validates :amount_in_stc, presence: true, exclusion: { in: [0] }
validates_inclusion_of :positive, :in => [true, false]

belongs_to :bet
belongs_to :user

scope :positive, lambda { where('bids.positive = ?', true) }
scope :negative, lambda { where('bids.positive = ?', false) }
scope :for_bet, lambda { |id| where('bids.bet_id = ?', id) }
scope :include_bets, lambda { joins(:bet) }

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

private

	def numeric(n) 
		s = n.to_s.gsub(',', '.')
		if s.to_i.to_s == s || s.to_f.to_s == s || s.to_f.to_s == "0" + s
			s
		else
			nil
		end
	end

end
