require 'rails_helper'

RSpec.describe Log, type: :model do
  describe "initial state" do
    it "has a default status of 'pending'" do
      log = Log.new
      expect(log.status).to eq("pending")
    end
  end
end
