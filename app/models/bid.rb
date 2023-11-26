class Bid < ActiveRecord::Base
  validates :user_id, presence: true
  validates :bet_id, presence: true
  validates :amount_in_stc, presence: true, exclusion: { in: [0] }
  validates_inclusion_of :positive, :in => [true, false]

  belongs_to :bet
  belongs_to :user

  scope :positive, -> { where('bids.positive = ?', true) }
  scope :negative, -> { where('bids.positive = ?', false) }
  scope :for_bet, ->(id) { where('bids.bet_id = ?', id) }
  scope :include_bets, -> { joins(:bet) }

  def amount_in_stc=(value)
    s = value.to_s.gsub(',', '.')
    self.amount = if s.to_i.to_s == s || s.to_f.to_s == s || s.to_f.to_s == "0#{s}"
                    (BigDecimal(s) * 100_000_000.0).to_i
                  else
                    0
                  end
  end

  def amount_in_stc
    amount / 100_000_000.0 unless amount.nil?
  end
end
