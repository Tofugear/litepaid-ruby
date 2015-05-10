module Litepaid
  class Refunds
    def initialize(client)
      @client = client
    end 

    # required: id, address
    def create(options)
      @client.ensure_valid_attributes options
      @client.ensure_presence_of_attributes %w(id address), options
      response = @client.make_request('refund', options)

      new_record response
    end    

    def new_record(response)
      Litepaid::Models::Refund.new response
    end

  end
end