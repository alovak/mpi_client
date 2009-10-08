require File.dirname(__FILE__) + '/../lib/mpi_client.rb'
require 'ruby-debug'

MPI_SERVER_URL = 'http://192.168.65.11/xml'

describe "MPIClient" do
  before(:each) do
    @mpi_client = MPIClient.new(MPI_SERVER_URL)
  end

  it "should create account, update, get_info and delete" do
    options = {
      :id           => 'some id',
      :site_name    => 'site name',
      :url          => 'http://siteurl/',
      :cert_subject => '*',
      :acquirer_bin => '3213',
      :country_code => '432',
      :password     => 'qwerty',
      :directory_server_url => 'http://www.visa.com/ds/',
      :brand        => '1',
      :response_url => 'http://www.response.com/gk/',
      :client_url   => 'http://www.client.com/',
      :term_url     => 'http://www.term.com/',
    }

    account_id = @mpi_client.create_account(options).account_id

    options.merge!({:account_id => account_id, :site_name => 'new_site_name'})

    @mpi_client.update_account(options).account_id.should == account_id
    @mpi_client.get_account_info({ :account_id => account_id }).site_name.should == options[:site_name]
    @mpi_client.delete_account({ :account_id => account_id }).account_id == account_id
  end
  
  it "should check card is enrolled and not enrolled" do
    account_id = '0'*32
    @mpi_client.enrolled({:account_id=>account_id, :card_number=>'4012001037141112'}).data[:status].should == 'Y'
    @mpi_client.enrolled({:account_id=>account_id, :card_number=>'4012001038443335'}).data[:status].should == 'N'
  end
end
