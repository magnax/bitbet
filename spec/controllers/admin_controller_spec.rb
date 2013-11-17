require 'spec_helper'

describe AdminController do

  describe "GET 'menu'" do
    it "returns http success" do
      get 'menu'
      response.should be_success
    end
  end

end
