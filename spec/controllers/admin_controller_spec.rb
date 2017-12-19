require 'spec_helper'

describe AdminController do
  before do
    @controller.current_user = User.new(:admin => true)
    @fake_client = Bitcoin::FakeClient.new
    @controller.stub(:bitcoin_client).and_return(@fake_client)
  end

  describe "GET menu" do
    it "shows admin menu" do
      get :menu
      expect(response).to render_template("menu")
    end
  end

  context "bitcoin client not working" do
    describe "GET transactions" do
      before do
        fake_client = Bitcoin::FakeClient.new
        fake_client.disable
        @controller.stub(:bitcoin_client).and_return(fake_client)
      end

      it "renders error on bitcoin client not working" do
        get :transactions
        expect(response).to redirect_to("/")
        flash[:error].should =~ /Bitcoin client not working/i
      end
    end
  end
end
