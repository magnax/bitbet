def sign_in(user, options={})
  if options[:no_capybara]
    # Sign in when not using Capybara.
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
  else
    visit login_path
    fill_in "Użytkownik",    with: user.name
    fill_in "Hasło", with: user.password
    click_button "Zaloguj się"
  end
end