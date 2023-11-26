module CheckUser
  def available_funds
    return unless operation_type == "send"

    user = User.find(user_id)
    return unless user.available_funds < amount

    errors.add(:amount_in_stc, :exceed)
  end
end