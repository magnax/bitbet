require 'spec_helper'

describe "User operations" do
  # before { User.any_instance.stub(:create_bitcoin_account).and_return(true) }
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
        allow_any_instance_of(Account).to receive(:valid_bitcoin_address).and_return(true)
        @bitcoin_client = double
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:operation, user: user)
        sign_in user
        visit withdraw_path
      end

      it { should have_content "Withdraw BTC from account" }
      it { should have_content "Available funds: 1,00000 BTC" }

      describe "withdraw submit with sufficient funds" do
        before do
          allow(@bitcoin_client).to receive(:sendfrom).with(any_args).and_return('abcde')
          allow_any_instance_of(OperationsController).to receive(:bitcoin_client).and_return(@bitcoin_client)
          fill_in "Amount", with: "0,9"
        end

        it "sends money from account" do
          expect do
            click_button "Withdraw"
            expect(page).to have_content "Successfull withdrawal of 0,9 BTC!"
          end.to change(Operation, :count).by 1
        end
      end

      describe "withdraw submit with insufficient funds" do
        before do
          allow(@bitcoin_client).to receive(:sendfrom).with(any_args).and_return('abcde')
          allow_any_instance_of(OperationsController).to receive(:bitcoin_client).and_return(@bitcoin_client)
          fill_in "Amount", with: "2"
        end

        it "sends money from account" do
          expect do
            click_button "Withdraw"
            expect(page).to have_content "Insufficient funds"
          end.to_not change(Operation, :count)
        end
      end

      describe "withdraw error" do
        before do
          @bitcoin_client = BitcoinClient.new
          allow(@bitcoin_client).to receive(:sendfrom).and_raise(BitcoinClient::ConnectionError)
          allow_any_instance_of(OperationsController).to receive(:bitcoin_client).and_return(@bitcoin_client)
          fill_in "Amount", with: "0,4"
        end

        it "sends money from account" do
          expect do
            click_button "Withdraw"
            expect(page).to have_content "Error sending money from account"
          end.to_not change(Operation, :count)
        end
      end
    end
  end
end
