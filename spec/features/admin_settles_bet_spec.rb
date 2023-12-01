require 'spec_helper'

describe 'Settle bet by admin' do
  before do
    allow_any_instance_of(Bitcoin::Client).to receive(:move).with(any_args).and_return('txid')
    @bet = create(:bet)
  end

  it 'settles empty bet' do
    @bet.settle(true)
    expect(@bet.reload.closed?).to eq true
  end

  describe 'with one bid' do
    before do
      create(:bid, bet: @bet)
    end

    it 'settles bet' do
      @bet.settle(true)
      expect(Operation.count).to eq 0
      expect(@bet.reload.closed?).to eq true
    end
  end

  describe 'with two proper bids' do
    before do
      @winner = create(:user)
      @loser = create(:user)
      create(:bid, bet: @bet, user: @winner, positive: true, amount_in_stc: 2)
      create(:bid, bet: @bet, user: @loser, positive: false, amount_in_stc: 1)
    end

    it 'settles bet' do
      @bet.settle(true)
      expect(Operation.count).to eq 3
      expect(@winner.available_funds).to eq 90_000_000
      expect(@bet.reload.closed?).to eq true
    end
  end
end
