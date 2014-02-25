require 'spec_helper'

describe Fee do
  
  before do
    mock_bitcoin
    User.any_instance.stub(:create_bitcoin_account).and_return(true)
    @fee = FactoryGirl.create(:fee)
  end

  subject { @fee }
  
  it { should be_valid }
end
