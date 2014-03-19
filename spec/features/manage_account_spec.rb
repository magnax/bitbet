require 'spec_helper'

describe "Managing account" do
  
  before do
    @bitcoin_client = BitcoinClient.new
    AccountsController.any_instance().stub(:bitcoin_client).and_return(@bitcoin_client)
  end

  subject { page }

  context "guest user" do
    describe "account create" do
      before { visit new_account_path }
      it { should have_content "Sign in" }
    end
  end

  context "signed in user" do
    let(:user) { FactoryGirl.create(:user) }

    describe "withdrawal address page" do
      before do
        sign_in user
        visit new_account_path
      end

      it { should have_content "Current withdrawal address: none" }

      describe "when account numer is valid" do
        before do
          Account.any_instance.stub(:valid_bitcoin_address).and_return(true)
          fill_in "BTC account number", with: "aaabbbcccddd"
        end

        it "creates new address" do
          expect{ click_button "Save" }.to change(Account, :count).by(1)
        end
      end
    end

    describe "when account number is invalid" do
      before do
        bc = double('BitcoinClient')
        BitcoinClient.stub(:new).and_return(bc)
        bc.stub(:validateaddress).with(anything()).and_return({ 'isvalid' => false })
        sign_in user
        visit new_account_path
        fill_in "BTC account number", with: "aaabbbcccddd"
      end

      it "don't create new address" do
        expect{ 
          click_button "Save"
          page.should have_content "Current withdrawal address:"
          page.should have_content "BTC account number is invalid"
        }.to_not change(Account, :count)
      end
    end

    describe "when client isn't working" do
      before do
        sign_in user
        visit new_account_path
        fill_in "BTC account number", with: "aaabbbcccddd"
      end

      it "don't create new address" do
        expect{ 
          click_button "Save"
          page.should have_content "BTC account number cannot be set when bitcoin client isn't working"
        }.to_not change(Account, :count)
      end
    end

    context "deposit address" do
      describe "user can set deposit address" do
        before do
          Account.any_instance.stub(:valid_bitcoin_address).and_return(true)
          @bitcoin_client.stub(:getnewaddress).with(any_args()).and_return('abcde')
          @bitcoin_client.stub(:setaccount).with(any_args()).and_return(true)
          sign_in user
          visit deposit_address_path
        end

        it { should have_content "Deposit address was successfully set" }
      end

      describe "when account cannot be saved" do
        before do
          Account.any_instance.stub(:valid_bitcoin_address).and_return(true)
          FactoryGirl.create(:account, account_type: "deposit", nr: "abcde")
          @bitcoin_client.stub(:getnewaddress).with(any_args()).and_return('abcde')
          sign_in user
          visit deposit_address_path
        end

        it { should have_content "Error setting deposit address" }
      end

      describe "when client isn't working" do
        before do
          @bitcoin_client.stub(:getnewaddress).and_raise(BitcoinClient::ConnectionError)
          sign_in user
          visit deposit_address_path
        end

        it { should have_content "Bitcoin client not working" }
      end
    end
  end
end