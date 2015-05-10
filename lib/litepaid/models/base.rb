module Litepaid
  module Models
    class Base

      INVOICE_STATUS = {
        created: 'ASN001',
        paid: 'ASC001',
        unconfirmed: 'ASC002',
        refund_requested: 'ASR001'
      }.freeze

      protected

      def get_status(key)
        INVOICE_STATUS.fetch(key)
      end

    end
  end
end