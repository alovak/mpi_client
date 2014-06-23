module MPIClient
  module AccountManagement
    class Response

      ATTRIBUTES = [:merchant_id, :site_name, :site_url,
                    :certificate_subject, :acquirer_bin, :country_code,
                    :password, :certificate, :private_key,
                    :directory_server_url, :brand, :response_url,
                    :client_url, :term_url, :account_id]

      attr_reader :response_source, :error_code, :error_message, :errors
      attr_reader *ATTRIBUTES

      def initialize(response_source)
        @response_source = response_source
      end

      def success?
        error_code.nil? && error_message.nil?
      end

      def parse
        doc = Nokogiri::XML.parse(response_source)
        case
        when error = doc.xpath("//Error").first
          @error_code    = error[:code]
          @error_message = error.text
          @errors        = errors_to_hash
        when (transaction = doc.xpath("//Transaction/*")) && transaction.any?
          set_account_attributes transaction
        else
          @error_message = 'Unknown response was received from MPI'
          @errors = errors_to_hash
        end
      end

      def data
        {}.tap do |result|
          ATTRIBUTES.each do |attr|
            result[attr] = send(attr)
          end
        end
      end

      private

      def errors_to_hash
        contain_error_fields? ? error_fields : {:base => error_message}
      end

      def error_fields
        {}.tap do |result|
          extract_messages(error_message).each do |message|
            key = OptionTranslator.to_client( field_name_from(message) )
            result[key.to_sym] = error_description_from(message)
          end
        end
      end

      def field_name_from(message)
        message.sub(/.+\[(.+)\].+/, '\1').to_sym
      end

      def error_description_from(message)
        message.sub /\s\[.+?\]/, ''
      end

      def extract_messages(message)
        message.sub(/.*\((.+)\).*/, '\1').split(/\.\s*/)
      end

      def contain_error_fields?
        error_code == 'C5'
      end

      def set_account_attributes(elements)
        elements.each do |element|
          name = OptionTranslator.to_client(element.name.to_sym)
          next unless name
          instance_variable_set("@#{name}".to_sym, element.text)
        end
      end

    end
  end
end
