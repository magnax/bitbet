Given(/^I have a published bet$/) do
  @bet = create(:published_bet)
  @bet.published_at.should == "2013-11-11 13:54:11"
  # RPC::JSON::Client.should_receive(:move).and_return(true)
end

Given(/^I am logged as admin$/) do
  @user = create(:admin)
  visit login_path
  fill_in "Użytkownik", with: @user.name
  fill_in "Hasło", with: "111111"
  click_button "Zaloguj się"
end

When(/^I choose to end bet as positive on settle page$/) do
  visit "/bets/#{@bet.id}/end"
  click_button "Zakończ jako PRAWDA"
end

Then(/^I should have this bet closed$/) do
  visit "/bets/#{@bet.id}"
  page.body.should =~ /Zdarzenie zakończone i rozliczone/m
end

Given(/^I have a users with amounts:$/) do |table|
  table.raw.each do |name, amount|
    bid_user = create(:user, { name: name })
    create(:operation, {
                         user_id: bid_user.id,
                         amount: amount * 100_000_000,
                         operation_type: "receive"
                       })
  end
end

Given(/^I have bids like:$/) do |table|
  table.raw.each do |name, amount, positive|
    user = User.find_by_name(name)
    Bid.create({ bet_id: @bet.id, user_id: user.id, amount_in_stc: amount, positive: positive })
  end
  # Bid.all.sum(:amount).should == 250000000
  # @bet.sum_positive.should == 150000000
end

Then(/^I should have "(.*?)" on "(.*?)" account$/) do |_arg1, _arg2|
  # @bet.sum_positive.should == 150000000
  # @bet.bids.positive.count.should == 2
  # fee = Fee.find_by_bet_id(@bet.id)
  # fee.amount.should == "500"
  Fee.all.count.should == 1
  # pending # express the regexp above with the code you wish you had
end

Then(/^I should have users with amounts:$/) do |table|
  table.raw.each do |name, _amount|
    user = User.find_by_name(name)
    user.available_funds.should
  end
end
