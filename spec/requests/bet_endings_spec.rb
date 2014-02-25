require 'spec_helper'

describe "BetEndings" do
    
  Timecop.freeze(Date.parse("2013-11-10"))
  let(:bet) { FactoryGirl.create(:published_bet) }

  subject { page }

  before do
    User.any_instance.stub(:create_bitcoin_account).and_return(true)
    @user = FactoryGirl.create(:admin)
    sign_in @user
  end

  describe "bets page" do
    it "should have button for ending bet" do
      visit bet_path bet
      expect(page).to have_content "Rozlicz"
    end

    context "bet settle" do
      before { mock_bitcoin }
      
      it "should have options for ending bet" do
        visit end_path bet
        expect(page).to have_content "Wybierz opcję zakończenia tego zdarzenia"
        expect(page).to have_xpath("//input[@name='positive']" )
        expect(page).to have_xpath("//input[@name='negative']" )
      end
    end
  end
end
