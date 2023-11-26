class Fee < ActiveRecord::Base
  include BitcoinHelper

  validate :amount_in_stc

  belongs_to :bet
end
