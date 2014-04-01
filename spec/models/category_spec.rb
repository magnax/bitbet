require 'spec_helper'

describe Category do
  let(:category) { Category.new(name: "Science") }
  
  subject { category }

  it { should be_valid }
end
