require 'spec_helper'

describe AdminController do
  before do
    @controller.current_user = User.new(:admin => true)
    @controller.stub!(:bitcoin_client).and_return(Bitcoin::FakeClient.new)
  end

  describe "GET menu" do
    it "shows admin menu" do
      get :menu
      expect(response).to render_template("menu")
    end
  end

  context "bitcoin client not working" do
    before { @controller.stub!(:bitcoin_client).and_return(Bitcoin::FakeClient.new :not_working) }

    describe "GET transactions" do
      it "renders error on bitcoin client not working" do
        get :transactions
        expect(response).to redirect_to("/")
        flash[:error].should =~ /Bitcoin client not working/i
      end
    end
  end

  context "bitcoin client working" do
    describe "GET transactions" do
      it "doesn't create operations on empty transaction list" do
        get :transactions
        expect(Operation.count).to eq(0)
        expect(assigns(:output)).to eq(['start', '----', 'end'])
      end
    end
  end
end
