require 'spec_helper'

describe "Bets listing" do
  it "shows list of bets" do
    visit bets_path
    expect(page).to have_content "Events"
  end

  context "for guest user" do
    it "redirects to login on new bet request" do
      visit new_bet_path
      expect(page).to have_content "Sign in"
    end

    it "redirects to 404 on non-existent bet" do
      get '/bets/666'
      expect(page).to redirect_to '/bets_404'
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
      expect(page).to have_content "Create new event"
    end

    it "creates new bet with valid inputs" do
      visit new_bet_path
      fill_in "Bet name", with: "My new bet"
      fill_in "Description", with: "My new bet description"
      select "Science", from: "Category"
      fill_in "Event date", with: Date.today + 10.days
      fill_in "Deadline", with: Date.today + 7.days
      expect do
        click_button "Save bet"
        expect(page).to have_content "Successfully added new bet event"
      end.to change(Bet, :count).by 1
    end

    it "renders 'new' view with invalid inputs" do
      visit new_bet_path
      fill_in "Bet name", with: "My new bet"
      expect { click_button "Save bet" }.to_not change(Bet, :count)
    end

    it "when bets is not visible" do
      @bet = FactoryGirl.create(:bet, user: FactoryGirl.create(:user))
      visit bet_path @bet
      expect(page).to have_content "Event was not found!"
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
      expect(page).to have_link "Publish"
      expect(page).to have_link "Reject"
    end

    it "can publish as admin" do
      click_link "Publish"
      expect(page).to have_content "Event was successfully published"
      expect(Bet.visible.count).to eq 1
    end

    describe "ban event" do
      before do
        @bet.publish!
        visit bet_path @bet
      end

      it "ban" do
        expect(page).to have_link "Ban (delete)"

        expect do
          click_link "Ban (delete)"
          expect(page).to have_content "Event was banned"
        end.to change(Bet.visible, :count).by(-1)
      end
    end

    it "can reject event" do
      expect do
        click_link "Reject"
        expect(page).to have_content "Event rejected"
        expect(page).to_not have_link "Reject"
      end.to_not change(Bet.visible, :count)
    end
  end
end
