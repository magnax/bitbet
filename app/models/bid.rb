class Bid < ActiveRecord::Base

validates :user_id, presence: true	
validates :bet_id, presence: true
validates :amount, presence: true, numericality: true
validates_inclusion_of :positive, :in => [true, false]

belongs_to :bet

scope :positive, lambda { where('bids.positive = ?', true) }
scope :negative, lambda { where('bids.positive = ?', false) }

before_validation :amount_in_stc

private

	def amount_in_stc
		def numeric(n) 
			s = n.to_s.gsub(',', '.')
			s.to_i.to_s == s || s.to_f.to_s == s
		end
		if !amount.nil?
			if numeric(amount_before_type_cast)
				self.amount = (100000000 * amount_before_type_cast.to_s.gsub(',', '.').to_f).to_i
			end
		end
	end

end
