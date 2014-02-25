require 'spec_helper'

describe Operation do
  
  before do
    mock_bitcoin
    User.any_instance.stub(:create_bitcoin_account).and_return(true)
    @operation = FactoryGirl.create(:operation)
  end

  subject { @operation }

  it { should be_valid }
end
