module Litepaid
  module Models
    class Refund < Base

      attr_accessor :token, :address, :status, :code, :message

      def initialize(options)
        options.each { |key, value|
          self.instance_variable_set "@#{key}", value
        }
      end
      
      def requested?
        @code == get_status(:refund_requested)
      end

    end
  end
end