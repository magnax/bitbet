require 'spec_helper'

describe ApplicationHelper do
  describe "#query_string" do
    let(:params) { { :status => 'active', :order => 'desc', :category => 'Polityka' } }

    it "returns proper string for default params" do
      key = nil
      value = nil
      expect(helper.query_string(params, key, value)).to eq "status=active&order=desc&category=Polityka"
    end

    it "returns proper string for status" do
      key = 'status'
      value = 'waiting'
      expect(helper.query_string(params, key, value)).to eq "status=waiting&order=desc&category=Polityka"
    end

    it "returns proper string for order" do
      key = 'order'
      value = 'asc'
      expect(helper.query_string(params, key, value)).to eq "status=active&order=asc&category=Polityka"
    end

    it "returns proper string for category" do
      key = 'category'
      value = 'Nauka'
      expect(helper.query_string(params, key, value)).to eq "status=active&order=desc&category=Nauka"
    end
  end
end
