require 'spec_helper'

describe "User pages" do

  context "for guest user" do
    it "shows form for create new user" do
      visit new_user_path
      page.should have_content "New user registration"
    end

    describe "Fail to create new user" do
      before do  
        visit new_user_path
      end

      it "renders form and error message" do
        expect{
          click_button "Register"
          page.should have_content "New user registration"
          page.should have_content "User name cannot be blank"
        }.to_not change(User, :count)
      end
    end
  end
end