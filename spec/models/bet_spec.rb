require 'spec_helper'

describe Bet do

	before do 
		Timecop.freeze(Date.parse("2013-11-15"))
		User.any_instance.stub(:create_bitcoin_account).and_return(true)
		@bet = FactoryGirl.create(:bet)
	end

	subject { @bet }

	it { should be_valid }

	describe "should not be valid without name" do
		before { @bet.name = "" }
		it { should_not be_valid }
	end

	describe "should not be valid without category" do
		before { @bet.category_id = "" }
		it { should_not be_valid }
	end

	describe "should not be valid with too short name" do
		before { @bet.name = "123456789" }
		it { should_not be_valid }
	end

	describe "should not be valid without description" do
		before { @bet.text = "" }
		it { should_not be_valid }
	end

	describe "bet dates" do

		describe "deadline" do

			describe "should not be valid when empty" do
				before { @bet.deadline = "" }
				it { should_not be_valid }
			end

			describe "should not be valid when not in proper date format" do
				before { @bet.deadline = "994*sdss01" }
				it { should_not be_valid }
			end

			describe "should not be valid when date in the past" do
				it "should be invalid" do
		    		dates = %w[2000-01-02 2013-09-01 2013-10-24 2013-10-25]
		      		dates.each do |invalid_date|
			        	@bet.deadline = invalid_date
			        	expect(@bet).not_to be_valid
			      	end
			    end
			    it "should be valid" do
		    		dates = %w[2013-11-26 2014-01-01]
		      		dates.each do |valid_date|
			        	@bet.deadline = valid_date
			        	@bet.event_at = "2014-01-10"
			        	expect(@bet).to be_valid
			      	end
			    end
			end

		end

		describe "event_at" do

			describe "should not be valid when empty" do
				before { @bet.event_at = "" }
				it { should_not be_valid }
			end

			describe "should not be valid when not in proper date format" do
				before { @bet.event_at = "994*sdss01" }
				it { should_not be_valid }
			end

			describe "should not be valid when date is too far" do
				before { @bet.event_at = "2015-03-26" }
				it { should_not be_valid }
			end

			describe "should not be valid when date in the past or too close to today" do
				it "should be invalid" do
		    		dates = %w[2000-01-02 2013-09-01 2013-10-24 2013-10-25 2013-10-26 2013-10-27]
		      		dates.each do |invalid_date|
			        	@bet.event_at = invalid_date
			        	@bet.deadline = "2000-01-01"
			        	expect(@bet).not_to be_valid
			      	end
			    end
			end

		    describe "deadline should be invalid when after event" do
	    		before do 
	    			@bet.event_at = "2013-11-20" 
	    			@bet.deadline = "2013-11-21"
	    		end
				it { should_not be_valid }
		    end

		    describe "deadline should be valid only when at least one day before event" do
	    		before do 
	    			@bet.event_at = "2013-11-20" 
	    			@bet.deadline = "2013-11-20"
	    		end
				it { should_not be_valid }
		    end

		end

	end

end
