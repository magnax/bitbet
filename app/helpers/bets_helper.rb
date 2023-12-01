# frozen_string_literal: true

module BetsHelper
  def view_as_btc(amount, precision)
    number_with_precision(stc_to_btc(amount), precision: precision, separator: ',', delimiter: '.')
  end

  def stc_to_btc(stc_amount)
    stc_amount / 100_000_000.0
  end
end
