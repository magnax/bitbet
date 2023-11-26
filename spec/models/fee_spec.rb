require 'spec_helper'

describe Fee do
  before { @fee = create(:fee) }

  subject { @fee }

  it { should be_valid }
end
