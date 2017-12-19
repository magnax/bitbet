require 'spec_helper'

describe "User operations" do
  #before { User.any_instance.stub(:create_bitcoin_account).and_return(true) }
  subject { page }

  context "guest user" do
    describe "withdraw page" do
      before { visit withdraw_path }
      it { should have_content "Sign in" }
    end
  end

  context "signed in user" do

    describe "withdrawal page" do
      before do
        Account.any_instance.stub(:valid_bitcoin_address).and_return(true)
        @bitcoin_client = double
        user = FactoryGirl.create(:user)
        deposit = FactoryGirl.create(:operation, user: user)
        sign_in user
        visit withdraw_path
      end

      it { should have_content "Withdraw BTC from account" }
      it { should have_content "Available funds: 1,00000 BTC" }

      describe "withdraw submit with sufficient funds" do
        before do
          @bitcoin_client.stub(:sendfrom).with(any_args()).and_return('abcde')
          OperationsController.any_instance.stub(:bitcoin_client).and_return(@bitcoin_client)
          fill_in "Amount", with: "0,9"
        end

        it "sends money from account" do
          expect { 
            click_button "Withdraw" 
            page.should have_content "Successfull withdrawal of 0,9 BTC!"
          }.to change(Operation, :count).by 1
        end
      end

      describe "withdraw submit with insufficient funds" do
        before do
          @bitcoin_client.stub(:sendfrom).with(any_args()).and_return('abcde')
          OperationsController.any_instance.stub(:bitcoin_client).and_return(@bitcoin_client)
          fill_in "Amount", with: "2"
        end

        it "sends money from account" do
          expect { 
            click_button "Withdraw" 
            page.should have_content "Insufficient funds"
          }.to_not change(Operation, :count)
        end
      end

      describe "withdraw error" do
        before do
          @bitcoin_client = BitcoinClient.new
          @bitcoin_client.stub(:sendfrom).and_raise(BitcoinClient::ConnectionError)
          OperationsController.any_instance.stub(:bitcoin_client).and_return(@bitcoin_client)
          fill_in "Amount", with: "0,4"
        end

        it "sends money from account" do
          expect { 
            click_button "Withdraw" 
            page.should have_content "Error sending money from account"
          }.to_not change(Operation, :count)
        end
      end
    end
  end
end
