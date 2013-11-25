require 'spec_helper'

describe "BetEndings" do
    
    subject { page }
    let(:user) { FactoryGirl.create(:admin) }
    before do
        @bet = FactoryGirl.create(:published_bet)
        sign_in user
    end

    describe "bets page" do
        before { visit "/bets/#{@bet.id}" }
        it "published bet should have button for ending bet" do
            expect(page).to have_content "Rozlicz"
        end
        describe "bet end page" do
            before { click_link "Rozlicz" }
            it "should have options for ending bet" do
                expect(page).to have_xpath("//input[@name='positive']" )
                expect(page).to have_xpath("//input[@name='negative']" )
            end
        end
    end

end
