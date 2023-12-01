# frozen_string_literal: true

def sign_in(user)
  visit login_path
  fill_in 'Username', with: user.name
  fill_in 'Password', with: user.password
  click_button 'Login'
end
