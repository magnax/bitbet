require 'spec_helper'

describe UsersController do
  describe 'renders error page when no bitcoin client' do
    render_views
    subject { get :new }

    before do
      fake_client = Bitcoin::FakeClient.new
      fake_client.disable
      allow(@controller).to receive(:bitcoin_client).and_return(fake_client)
    end

    it 'renders template' do
      expect(subject).to render_template 'errors/error'
    end
  end
end
