require 'spec_helper'

describe Fee do
  before { @fee = FactoryGirl.create(:fee) }

  subject { @fee }
  
  it { should be_valid }
end
