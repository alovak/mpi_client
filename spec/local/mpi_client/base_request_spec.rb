require 'spec_helper'

describe "BaseRequest" do
  describe "filter_xml_data" do
    it "should replace fields in XML" do
      request = BaseRequest.new
      xml = <<-XML
        <xml>
          <user>secret</user>
          <password>password</password>
          <data>not secret</data>
        </xml>
      XML

      xml = request.send(:filter_xml_data, xml, :user, :password)

      xml.should =~ /<user>\[FILTERED\]<\/user>/
      xml.should =~ /<password>\[FILTERED\]<\/password>/
      xml.should =~ /<data>not secret<\/data>/
    end
  end

  describe "proxy settings" do
    let(:proxy_addr) { "http://proxy.com" }
    let(:proxy_port) { 3129 }
    let(:proxy_user) { "p_user" }
    let(:proxy_pass) { "p_pass" }

    before do
      MPIClient.proxy_addr = proxy_addr
      MPIClient.proxy_port = proxy_port
      MPIClient.proxy_user = proxy_user
      MPIClient.proxy_pass = proxy_pass
    end

    after do
      MPIClient.proxy_addr = nil
      MPIClient.proxy_port = nil
      MPIClient.proxy_user = nil
      MPIClient.proxy_pass = nil
    end

    it "should create connection with proxy" do
      connection = MPIClient::BaseRequest.new.connection

      connection.instance_variable_get(:@proxy_addr).should == proxy_addr
      connection.instance_variable_get(:@proxy_port).should == proxy_port
      connection.instance_variable_get(:@proxy_user).should == proxy_user
      connection.instance_variable_get(:@proxy_pass).should == proxy_pass
    end
  end

end
