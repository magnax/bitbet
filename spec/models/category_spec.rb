require 'spec_helper'

describe Category do
  let(:category) { FactoryGirl.create(:category) }
  
  subject { category }

  it { should be_valid }
end
