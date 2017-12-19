require 'spec_helper'

describe "User account tests" do
  before do
    @bitcoin_client = Bitcoin::FakeClient.new
    allow_any_instance_of(UsersController).to receive(:bitcoin_client).and_return(@bitcoin_client)
    visit new_user_path
    fill_in "User name", with: "bob"
    fill_in "E-mail", with: "bob@mail.com"
    fill_in "Password", with: "11111111"
    fill_in "Password confirmation", with: "11111111"
  end

  it "creates new user" do
    expect {
      click_button "Register"
      expect(page).to have_content "Your account was created"
    }.to change(User, :count).by 1
  end

  it "shows notice when bitcoin account can't be created" do
    allow(@bitcoin_client).to receive(:create_user_account).with(anything()).and_return(false)
    expect {
      click_button "Register"
      expect(page).to have_content "Failed to create bitcoin account"
    }.to change(User, :count).by 1
  end

  it "redirects to home when rpc client isn't working" do
    @bitcoin_client.disable
    expect {
      click_button "Register"
      expect(page).to have_content "Bitcoin client not working"
    }.to change(User, :count).by 1
  end
end
