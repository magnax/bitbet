# frozen_string_literal: true

require 'spec_helper'

describe 'BetEndings' do
  Timecop.freeze(Date.parse('2013-11-10'))
  let(:bet) { create(:bet, :published) }
  Timecop.return

  subject { page }

  before do
    @bitcoin_client = Bitcoin::Client.new
    allow_any_instance_of(BetsController).to receive(:bitcoin_client).and_return(@bitcoin_client)
    @user = create(:user, :admin)
    sign_in @user
  end

  describe 'bets page' do
    it 'should have button for ending bet' do
      visit bet_path bet
      expect(page).to have_content 'Settle'
    end

    context 'bet settle' do
      before { visit end_path bet }

      it 'should have options for ending bet' do
        expect(page).to have_content 'Choose one option to settle this event'
        expect(page).to have_xpath("//input[@name='positive']")
        expect(page).to have_xpath("//input[@name='negative']")
      end

      it 'actually settles bet' do
        allow_any_instance_of(Bitcoin::Client).to receive(:move).with(any_args).and_return('txid')
        click_button 'Settle as TRUE'
        expect(page).to have_content 'Event was successfully settled'
      end
    end
  end

  it 'should not settle bet which is already closed' do
    bet.closed_at = DateTime.parse('2013-11-25')
    bet.save
    visit end_path bet
    expect(page).to have_content 'This event cannot be settled'
  end
end
