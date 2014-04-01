module BitcoinHelper

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
end
