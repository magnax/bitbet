require 'spec_helper'

describe "Managing sessions" do
  subject { page }
  before { visit login_path }

  describe "fails to login with invalid credentials" do
    before do
      fill_in "Username", with: ""
      fill_in "Password", with: ""
      click_button "Login"
    end

    it { should have_content 'Invalid username or password' }
  end

  describe "Log out" do
    before do
      @user = create(:user)
      sign_in @user
    end

    it "should log out properly" do
      click_link "Logout"
      expect(page).to have_content "You are logged out"
    end
  end
end
