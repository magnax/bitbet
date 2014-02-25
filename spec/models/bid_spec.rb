require 'spec_helper'

describe Bid do
  	
  	before { @bid = Bid.new(
  			user_id: 1,
  			bet_id: 1,
  			amount_in_stc: 1,
  			positive: true
  		) }

	subject { @bid }

	it { should be_valid }
	it { should respond_to(:amount_in_stc) }

    describe "should not be valid without user_id" do
        before { @bid.user_id = nil }
        it { should_not be_valid }
    end

    describe "should not be valid without bet_id" do
        before { @bid.bet_id = nil }
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
    
	describe "should be invalid without amount" do
		before { @bid.amount_in_stc = " " }
		it { should_not be_valid }
	end

	describe "should be invalid without amount" do
		before { @bid.amount_in_stc = "0" }
		it { should_not be_valid }
	end

	describe "should be invalid with invalid amount" do
		before { @bid.amount_in_stc = "asdfg" }
		it { should_not be_valid }
	end

	describe "should be invalid with invalid amount" do
		before { @bid.amount_in_stc = "3a" }
		it { should_not be_valid }
	end

	describe "valid cases" do
		its(:amount) { should eq 100_000_000 }

		it "should be valid" do
			inputs = %w[0,2 3.3 3 .2 ,34]
	  		inputs.each do |valid_input|
	        	@bid.amount_in_stc = valid_input
	        	expect(@bid).to be_valid
	      	end
	    end
	end

	it "should be invalid" do
		inputs = %w[0,,2 asdf 3a 3..3]
  		inputs.each do |invalid_input|
        	@bid.amount_in_stc = invalid_input
        	expect(@bid).not_to be_valid
      	end
    end

end
