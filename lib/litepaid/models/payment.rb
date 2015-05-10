module Litepaid
  module Models
    class Payment < Base

      attr_accessor :token, :payment_url, :code, :message, :status

      def initialize(options)
        options.each { |key, value|
          self.instance_variable_set "@#{key}", value
        }
      end

      # invoice created and open
      def open?
        @code == get_status(:created)
      end

      # payment complete
      def paid?
        @code == get_status(:paid)
      end

      # paid but unconfirmed
      def unconfirmed?
        @code == get_status(:unconfirmed)
      end
    end
  end
end