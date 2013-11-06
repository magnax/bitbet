require 'spec_helper'

describe Bid do
  	
  	before { @bid = FactoryGirl.create(:bid) }

	subject { @bid }

	it { should be_valid }

	describe "should not be valid without user_id" do
		before { @bid.user_id = nil }
		it { should_not be_valid }
	end

	describe "should not be valid without bet_id" do
		before { @bid.bet_id = nil }
		it { should_not be_valid }
	end

	describe "should not be valid without amount" do
		before { @bid.amount = nil }
		it { should_not be_valid }
	end

	describe "should be invalid with not valid amount" do
		before { @bid.amount = "aassdd" }
		it { should_not be_valid }
	end

	describe "should not be valid without positive" do
		before { @bid.positive = nil }
		it { should_not be_valid }
	end

	describe "should be valid with positive set to 0" do
		before { @bid.positive = 0 }
		it { should be_valid }
	end

	describe "should be valid with valid string" do
		before { @bid.amount = "0,33" }
		it { should be_valid }
	end

	it "should be invalid" do
		inputs = %w[0,,2 asdf 3..3 3a]
  		inputs.each do |invalid_input|
        	@bid.amount = invalid_input
        	expect(@bid).not_to be_valid
      	end
    end

    it "should be valid" do
		inputs = %w[0,2 3.3 3]
  		inputs.each do |valid_input|
        	@bid.amount = valid_input
        	expect(@bid).to be_valid
      	end
    end

	describe "amount" do

		describe "should be converted to satoshi" do
      		before do
	        	@bid.amount = "0.1"
	        	@bid.save
	        end
	        its(:amount) { should eq 10_000_000 }
		end

		describe "should be converted to satoshi" do
      		before do
	        	@bid.amount = "0,2"
	        	@bid.save
	        end
	        its(:amount) { should eq 20_000_000 }
		end

	end

end
