require 'spec_helper'

describe "Bets listing" do

  it "shows list of bets" do
    visit bets_path
    page.should have_content "Events"
  end

  context "for guest user" do
    it "redirects to login on new bet request" do
      visit new_bet_path
      page.should have_content "Sign in"
    end

    it "redirects to 404 on non-existent bet" do
      get 'bets/666'
      page.should redirect_to '/bets_404'
    end
  end

  context "for standard user" do
    before do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:category)
      sign_in user
    end

    it "shows new bet form" do
      visit new_bet_path
      page.should have_content "Create new event"
    end

    it "creates new bet with valid inputs" do
      visit new_bet_path
      fill_in "Bet name", with: "My new bet"
      fill_in "Description", with: "My new bet description"
      select "Science", from: "Category"
      fill_in "Event date", with: Date.today + 10.days
      fill_in "Deadline", with: Date.today + 7.days
      expect{ 
        click_button "Save bet"
        page.should have_content "Successfully added new bet event"
      }.to change(Bet, :count).by 1
    end

    it "renders 'new' view with invalid inputs" do
      visit new_bet_path
      fill_in "Bet name", with: "My new bet"
      expect{ click_button "Save bet" }.to_not change(Bet, :count)
    end

    it "when bets is not visible" do
      @bet = FactoryGirl.create(:bet, user: FactoryGirl.create(:user))
      visit bet_path @bet
      page.should have_content "Event was not found!"
    end
  end

  context "for admins" do
    before do
      admin = FactoryGirl.create(:admin)
      FactoryGirl.create(:category)
      @bet = FactoryGirl.create(:bet, user: FactoryGirl.create(:user))
      sign_in admin
      visit bet_path @bet
    end

    it "should be link to publish" do
      page.should have_link "Publish"
      page.should have_link "Reject"
    end

    it "can publish as admin" do
      expect { 
        click_link "Publish"
        page.should have_content "Event was successfully published"
      }.to change(Bet.visible, :count).by 1
    end

    describe "ban event" do
      before do
        @bet.publish!
        visit bet_path @bet
      end

      it "ban" do
        page.should have_link "Ban (delete)"

        expect { 
          click_link "Ban (delete)"
          page.should have_content "Event was banned"
        }.to change(Bet.visible, :count).by -1
      end
    end

    it "can reject event" do
      expect { 
        click_link "Reject"
        page.should have_content "Event rejected"
        page.should_not have_link "Reject"
      }.to_not change(Bet.visible, :count)
    end
  end
end