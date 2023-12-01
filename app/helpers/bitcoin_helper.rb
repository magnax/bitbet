# frozen_string_literal: true

module BitcoinHelper
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
