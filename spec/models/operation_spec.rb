require 'spec_helper'

describe Operation do
  before do
    allow_any_instance_of(Account).to receive(:valid_bitcoin_address).and_return(true)
    @operation = create(:operation)
  end

  subject { @operation }

  it { should be_valid }
end
