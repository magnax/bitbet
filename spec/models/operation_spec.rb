require 'spec_helper'

describe Operation do  
  before do
    Account.any_instance.stub(:valid_bitcoin_address).and_return(true)
    @operation = FactoryGirl.create(:operation)
  end

  subject { @operation }

  it { should be_valid }
end
