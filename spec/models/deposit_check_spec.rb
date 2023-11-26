require 'json'
require_relative '../../app/models/deposit/check'
require_relative '../../app/models/deposit/deposit_user'
require_relative '../../app/models/bitcoin/fake_client'

describe Deposit::Check do
  before do
    @fake_client = Bitcoin::FakeClient.new
    @deposit_check = Deposit::Check.new(@fake_client)
  end

  context "when bitcoin client not working" do
    before { @fake_client.disable }

    it "returns error message" do
      expect do
        @deposit_check.check
      end.to raise_error(Bitcoin::ConnectionError)
    end
  end

  context "when client is working" do
    it "runs" do
      expect(@deposit_check.check).to eq %w[start end]
    end

    describe "skip not user (ie. technical) accounts" do
      before do
        @fake_client.set_response_for('listaccounts',
                                      { "" => 0.00000000, "fees" => 0.00000000 })
      end

      it "outputs proper message" do
        expect(@deposit_check.check).to eq ['start', "skip: ''", "skip: 'fees'", 'end']
      end
    end

    context "transactions" do
      before do
        @fake_client.set_response_for('listaccounts',
                                      { "user_1" => 0.04400000 })
        allow(Deposit::DepositUser).to receive(:new).and_return(double(
                                                                  :get_last_deposit_id => '12345678'
                                                                ))
      end

      describe "empty transaction list" do
        before do
          @fake_client.set_response_for('listtransactions', [])
        end

        it "outputs proper message" do
          expect(@deposit_check.check).to include("account: 'user_1'",
                                                  "-- no transactions for 'user_1' --")
        end
      end

      describe "when last transaction in client is the last registered" do
        before { fake_client_response :only_last_registered_transaction }

        it "outputs proper message" do
          expect(@deposit_check.check).to include(
            "account: 'user_1'", "-- existing transaction met --"
          )
        end
      end

      describe "when last transaction has not proper type" do
        before { fake_client_response :one_other_transaction }

        it "outputs proper message" do
          expect(@deposit_check.check).to eq [
            'start', "account: 'user_1'",
            "-- end of transactions for 'user_1' --",
            "-- end 'user_1'", "end"
          ]
        end
      end

      describe "when last transaction has too few confirmations" do
        before { fake_client_response :not_enough_confirmations }

        it "outputs proper message" do
          expect(@deposit_check.check).to include(
            "account: 'user_1'",
            "-- not enough confirmations (0/3) for 0.6 BTC --"
          )
        end
      end

      describe "saving first transaction" do
        before do
          fake_client_response :one_good_first_transaction
          allow(Deposit::DepositUser).to receive(:new)
                                     .and_return(double(
                                                   :get_last_deposit_id => nil, :create_new_deposit => true
                                                 ))
        end

        it "outputs proper message" do
          expect(@deposit_check.check).to include(
            "account: 'user_1'",
            "-- deposited 0.6 BTC for 'user_1' --"
          )
        end
      end

      describe "skip two transactions with not enough confirmations" do
        before do
          fake_client_response :two_unconfirmed_transactions
          allow(Deposit::DepositUser).to receive(:new).and_return(double(
                                                                    :get_last_deposit_id => nil
                                                                  ))
        end

        it "outputs proper message" do
          expect(@deposit_check.check).to include(
            "account: 'user_1'",
            "-- not enough confirmations (1/3) for 0.6 BTC --",
            "-- not enough confirmations (2/3) for 0.1 BTC --"
          )
        end
      end
    end
  end

  def fake_client_response(key)
    t = JSON.parse(File.read('spec/fixtures/transactions.json'))
    @fake_client.set_response_for('listtransactions', t[key.to_s])
  end
end
