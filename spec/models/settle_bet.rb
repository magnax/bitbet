# frozen_string_literal: true

require 'spec_helper'

describe Bet do
  before do
    @bet = create(:published_bet)
    @maniek = create(:user)
    create(:operation, {
             user_id: @maniek.id,
             amount: 200_000_000,
             operation_type: 'receive'
           })
    @sid = create(:user)
    create(:operation, {
             user_id: @sid.id,
             amount: 100_000_000,
             operation_type: 'receive'
           })
    @ella = create(:user)
    create(:operation, {
             user_id: @ella.id,
             amount: 120_000_000,
             operation_type: 'receive'
           })
    Bid.create({ bet_id: @bet.id, user_id: @maniek.id, amount_in_stc: 1.0, positive: true })
    Bid.create({ bet_id: @bet.id, user_id: @sid.id, amount_in_stc: 0.5, positive: true })
    Bid.create({ bet_id: @bet.id, user_id: @ella.id, amount_in_stc: 1.0, positive: false })
  end

  subject { @bet }

  describe 'maniek should have some amount' do
    it '' do
      expect(@maniek.available_funds).to eq 100_000_000
    end
  end

  it 'should have bids' do
    expect(@bet.bids.count).to eq 3
    expect(@bet.bids.positive.count).to eq 2
    expect(@bet.bids.negative.count).to eq 1
  end

  it 'should have correct sum of positive bids' do
    expect(@bet.sum_positive).to eq 150_000_000
  end

  it 'should have correct sum of negative bids' do
    expect(@bet.sum_negative).to eq 100_000_000
  end

  it 'should have participants' do
    expect(@bet.participants.count).to eq 3
  end

  describe 'settle bet as positive' do
    before { @bet.settle(true) }

    it 'should be ended' do
      expect(@bet.positive).to eq true
      expect(@bet.closed_at).not_to eq nil
    end

    it 'should create operation for creator commision' do
      o = Operation.commissions.first
      expect(o.amount).to eq 5_000_000
    end

    it 'should have total of 7 operations' do
      expect(Operation.all.count).to eq 7
    end

    it 'should have 2 winnings' do
      expect(Operation.winnings.count).to eq 2
    end

    it 'should have 1 losings' do
      expect(Operation.losings.count).to eq 1
    end

    it 'should have fee' do
      expect(Fee.all.count).to eq 1
      f = Fee.first
      expect(f.amount).to eq 5_000_000
    end
  end

  describe 'settle bet as negative' do
    before { @bet.settle(false) }

    it 'should be ended' do
      expect(@bet.positive).to eq false
    end

    it 'should create operation for creator commision' do
      o = Operation.commissions.first
      expect(o.amount).to eq 7_500_000
    end

    it 'should have total of 7 operations' do
      expect(Operation.all.count).to eq 7
    end

    it 'should have 1 winnings' do
      expect(Operation.winnings.count).to eq 1
    end

    it 'should have 2 losings' do
      expect(Operation.losings.count).to eq 2
    end
  end
end
