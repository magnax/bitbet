# frozen_string_literal: true

require 'spec_helper'

describe Account do
  it 'is valid' do
    expect(build(:account)).to be_valid
  end
end
