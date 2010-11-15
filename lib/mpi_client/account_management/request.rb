module MPIClient
  module AccountManagement
    class Request < MPIClient::BaseRequest
      FILTERED_FIELDS = %w(Password PublicCertificate PrivateKey)
      CLIENT_METHODS  = %w(create_account get_account_info update_account delete_account verify)

      def method_missing(method, *args)
        submit_request(method, *args) if CLIENT_METHODS.include?(method.to_s)
      end

      private
      def submit_request(request_type, *args)
        response = connection.post(prepare_request_data(request_type, *args))
        parse_response(response.body)
      end

      def prepare_request_data(request_type, options, transaction_attrs = {})
        options = options.dup
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.REQUEST(:type => request_type) do |xml|
            xml.Transaction(transaction_attrs) do |xml|
              options.each do |k,v|
                xml.send(OptionTranslator.to_server(k), v)
              end
            end
          end
        end
        builder.to_xml
      end

      def parse_response(response_data)
        response = Response.new(response_data)
        response.parse
        response
      end
    end
  end
end
