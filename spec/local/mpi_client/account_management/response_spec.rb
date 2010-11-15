require 'spec_helper'

describe AccountManagement::Response do
  let(:response_source) { 'RESPONSE' }
  let(:response) { AccountManagement::Response.new(response_source) }

  it "should initialize response source" do
    response.response_source.should == response_source
  end

  describe "#errors_to_hash" do
    let(:error_code)    { 'S3 '}
    let(:error_message) { 'Can\'t create merchant certificate (Error unable to get local issuer certificate getting chain.)' }

    before do
      response.instance_variable_set(:@error_code, error_code)
      response.instance_variable_set(:@error_message, error_message)
    end

    subject { response.send(:errors_to_hash) }

    context "if contain error fields" do
      let(:error_fields) { mock }

      before { response.stub(:contain_error_fields? => true) }

      it "should return error fields" do
        response.should_receive(:error_fields).and_return(error_fields)

        should == error_fields
      end
    end

    it "should return a hash of the form {:base => error_message}" do
      should == {:base => error_message}
    end
  end

  describe "#field_name_from" do
    subject { response.send(:field_name_from, 'Mandatory parameter [Id] is empty') }

    it "should return field name from message" do
      should == :Id
    end
  end

  describe "#error_description_from" do
    subject { response.send(:error_description_from, 'Mandatory parameter [Id] is empty') }

    it "should return error description from message" do
      should == 'Mandatory parameter is empty'
    end
  end

  describe "#extract_messages" do
    subject { response.send(:extract_messages, 'Wrong (format. fields)') }

    it "should return message in parentheses" do
      should == %w(format fields)
    end
  end

  describe "#contain_error_fields?" do
    subject { response.send(:contain_error_fields?) }

    context "if response contains error fields" do
      before { response.stub(:error_code => 'C5') }

      it { should be_true}
    end

    context "if response not contains error fields" do
      before { response.stub(:error_code => 'S3') }

      it { should be_false}
    end

  end

  describe "#error_fields" do
    let(:error_message) { 'Wrong data format (Mandatory parameter [URL] is empty. Mandatory parameter [Id] is empty.)' }

    before { response.instance_variable_set(:@error_message, error_message) }

    subject { response.send(:error_fields) }

    it "should return a hash of the form {:field_name => error_description} with all the wrong fields" do
      expected_result = {
        :site_url    => 'Mandatory parameter is empty',
        :merchant_id => 'Mandatory parameter is empty'
      }

      should == expected_result
    end

  end

  describe "#success?" do

    subject { response.success? }

    context "if no error code and error message" do

      it { should be_true }
    end

    context "if have error code and/or error message" do
      before { response.instance_variable_set(:@error_code, 'S3') }

      it { should be_false }
    end

  end

  describe "#set_account_attributes" do
    let(:xml) { '<Transaction><CardType>visa</CardType><Id>33</Id></Transaction>'}
    let(:doc) { Nokogiri::XML(xml) }

    it "should setting properties account" do
      response.send(:set_account_attributes, doc.xpath("//Transaction/*"))

      response.brand.should         == 'visa'
      response.merchant_id.should   == '33'
    end
  end

  describe "#parse" do
    let(:response_source) { "" }

    before { response.instance_variable_set(:@response_source, response_source) }

    context "when response contains errors" do
      let(:errors)          { mock }
      let(:response_source) { "<Error code='C2'>Wrong request</Error>" }

      before do
        response.should_receive(:errors_to_hash).and_return(errors)
        response.parse
      end

      it "should set error_code" do
        response.error_code.should    == 'C2'
      end

      it "should set error_message" do
        response.error_message.should == 'Wrong request'
      end

      it "should set errors" do
        response.errors.should == errors
      end
    end

    context "when response contains account information" do
      let(:doc)      { mock }
      let(:elements) { mock }
      let(:response_source) { "<Transaction><Id>33</Id></Transaction>" }

      before do
        Nokogiri::XML.should_receive(:parse).with(response_source).and_return(doc)
        doc.should_receive(:xpath).with("//Error").and_return([])
        doc.should_receive(:xpath).with("//Transaction/*").and_return(elements)
      end

      it "should set account properties" do
        response.should_receive(:set_account_attributes).with(elements)

        response.parse
      end
    end
  end

end
