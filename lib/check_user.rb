module CheckUser

def available_funds
	user = User.find(user_id)
	if user.available_funds < amount
		errors.add(:amount_in_stc, :exceed)
	end

end

end