require 'spec_helper'

describe "Settle bet by admin" do
  before do
    mock_bitcoin
    User.any_instance.stub(:create_bitcoin_account).and_return(true)
    @bet = FactoryGirl.create(:bet)
  end

  it "settles empty bet" do
    @bet.settle(true)
    expect(@bet.reload.closed?).to eq true
  end

  describe "with one bid" do
    before do
      FactoryGirl.create(:bid, bet: @bet)
    end
    
    it "settles bet" do
      @bet.settle(true)
      expect(Operation.count).to eq 0
      expect(@bet.reload.closed?).to eq true
    end    
  end

  describe "with two proper bids" do
    before do
      @winner = FactoryGirl.create(:user)
      loser = FactoryGirl.create(:user)
      FactoryGirl.create(:bid, bet: @bet, user: @winner, positive: true, amount_in_stc: 2)
      FactoryGirl.create(:bid, bet: @bet, user: loser, positive: false, amount_in_stc: 1)
    end
    
    it "settles bet" do
      @bet.settle(true)
      expect(Operation.count).to eq 3
      expect(@winner.available_funds).to eq 90000000
      expect(@bet.reload.closed?).to eq true
    end    
  end
end