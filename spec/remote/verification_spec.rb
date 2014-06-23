require 'spec_helper'

describe 'test of verification request' do
  it "should have status 'N'" do
    req = Verification::Request.new(request_params(:card_number => '4012001038443335'), '1')
    response = req.process
    response.status.should == 'N'
  end

  it "should return 'Y' and url" do
    req = Verification::Request.new(request_params(:card_number => '4200000000000000'), '2')
    response = req.process
    response.status.should == 'Y'
    response.url.should_not be_empty
  end

  def request_params(new_params)
    { :account_id       => 'd6d8479f23a526b4e676c88759abd27a',
      :amount           => '100',
      :card_number      => '4200000000000000',
      :description      => 'Test order',
      :display_amount   => '1 USD',
      :currency         => '840',
      :exp_month        => '12',
      :exp_year         => '16',
      :termination_url  => 'http://termurl.com'
    }.update(new_params)
  end
end
