require 'spec_helper'

describe "Managing account" do
  let(:user) { FactoryGirl.create(:user) }
  let(:bitcoin_client) { Bitcoin::FakeClient.new }

  before do
    allow_any_instance_of(AccountsController)
      .to receive(:bitcoin_client).and_return(bitcoin_client)
  end

  subject { page }

  context "guest user" do
    describe "account create" do
      before { visit new_account_path }
      it { should have_content "Sign in" }
    end
  end

  context "signed in user" do
    before do
      allow_any_instance_of(Account)
        .to receive(:bitcoin_client).and_return(bitcoin_client)
      sign_in user
      visit new_account_path
    end

    describe "withdrawal address page" do
      it { should have_content "Current withdrawal address: none" }

      describe "when account numer is valid" do
        before { fill_in "BTC account number", with: "aaabbbcccddd" }

        it "creates new address" do
          expect { click_button "Save" }.to change(Account, :count).by(1)
        end
      end
    end

    describe "when account number is invalid" do
      before do
        bitcoin_client.set_response_for('validateaddress',
                                        { "isvalid" => false })
        fill_in "BTC account number", with: "aaabbbcccddd"
      end

      it "don't create new address" do
        expect  do
          click_button "Save"
          expect(page).to have_content "Current withdrawal address:"
          expect(page).to have_content "BTC account number is invalid"
        end.to_not change(Account, :count)
      end
    end

    describe "when client isn't working" do
      before do
        bitcoin_client.disable
        fill_in "BTC account number", with: "aaabbbcccddd"
      end

      it "don't create new address" do
        expect  do
          click_button "Save"
          expect(page).to have_content "BTC account number cannot be set when bitcoin client isn't working"
        end.to_not change(Account, :count)
      end
    end

    context "deposit address" do
      describe "user can set deposit address" do
        before { visit deposit_address_path }

        it { should have_content "Deposit address was successfully set" }
      end

      describe "when account cannot be saved" do
        before do
          FactoryGirl.create(:account, account_type: "deposit", nr: "abcde")
          visit deposit_address_path
        end

        it { should have_content "Error setting deposit address" }
      end

      describe "when client isn't working" do
        before do
          bitcoin_client.disable
          visit deposit_address_path
        end

        it { should have_content "Bitcoin client not working" }
      end
    end
  end
end
