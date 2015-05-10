module Litepaid
  class Exception < StandardError
    attr_reader :status, :code
    def initialize(message, status = nil, code = nil)
      super message
      @status = status
      @code = code
    end  
  end
end
