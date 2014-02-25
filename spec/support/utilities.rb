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

def mock_bitcoin
  bc_mock = double("bc")
  bc_mock.stub(:validateaddress).with(any_args()).and_return({'isvalid' => true})
  bc_mock.stub(:getnewaddress).and_return('1234')
  bc_mock.stub(:setaccount).and_return(true)
  bc_mock.stub(:move).with(any_args()).and_return(true)
  RPC::JSON::Client.stub!(:new).and_return(bc_mock)
end