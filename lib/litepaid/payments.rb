module Litepaid
  class Payments
    def initialize(client)
      @client = client
    end

    # required: value, return_url
    # optional: cancel_url, currency, webhook_url, description
    def create(options)
      @client.ensure_valid_attributes options
      @client.ensure_presence_of_attributes %w(value return_url), options
      response = @client.make_request('create-invoice', options)

      token = response.delete(:invoice_token)
      response[:token] = token
      response[:payment_url] = response.delete(:invoice_location) || "#{Litepaid::Client::INVOICE_URL}/id:#{token}"

      new_record response
    end

    # required: id
    def get(id)
      options = { id: id}
      @client.ensure_valid_attributes options
      @client.ensure_presence_of_attributes %w(id), options
      response = @client.make_request('check-invoice-status', options)

      response[:token] = id

      new_record response
    end      

    def new_record(response)
      Litepaid::Models::Payment.new response
    end

  end
end