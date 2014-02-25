require 'spec_helper'

describe "Managing account" do
  before { User.any_instance.stub(:create_bitcoin_account).and_return(true) }
  subject { page }

  context "guest user" do
    describe "account create" do
      before { visit new_account_path }
      it { should have_content "zaloguj się" }
    end
  end

  context "signed in user" do
    let(:user) { FactoryGirl.create(:user) }

    describe "withdrawal address page" do
      before do
        mock_bitcoin
        sign_in user
        visit new_account_path
      end

      it { should have_content "Obecny adres: brak" }

      describe "create account" do
        before do
          fill_in "Numer konta BTC:", with: "aaabbbcccddd"
        end

        it "creates new address" do
          expect{ click_button "Zapisz" }.to change(Account, :count).by(1)
        end
      end
    end
  end
end