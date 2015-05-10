require 'uri'
require 'json'
require 'rest_client'

require 'litepaid/models/base'
require 'litepaid/models/payment'
require 'litepaid/models/refund'
require 'litepaid/payments'
require 'litepaid/refunds'

module Litepaid
  class Client
    API_URL = 'https://www.litepaid.com/api'
    INVOICE_URL = 'https://www.litepaid.com/invoice'    
    API_MODES = {
      live: 0,
      test: 1
    }.freeze

    attr_reader :payments, :refunds

    # required: key
    # optional: mode, version
    def initialize(options)

      options = options.clone
      if options.kind_of?(String)
        { key: options }
      end

      ensure_valid_attributes options
      ensure_presence_of_attributes %w(key), options

      options[:mode] = (options.delete(:mode) || 'live').downcase

      @api_version  = options.delete(:version) || 2         
          
      @options  = options.freeze

      @payments = Litepaid::Payments.new self
      @refunds = Litepaid::Refunds.new self

    end

    def ensure_presence_of_attributes(keys, attributes)
      raise ArgumentError, 'Options Hash is expected' if attributes.nil?

      attributes = attributes.with_indifferent_access

      keys.each do |key|
        unless attributes.has_key?(key) && attributes[key].present?
          raise ArgumentError, ":#{key} not found or is empty"
        end
      end
    end

    def ensure_valid_attributes(attributes)
      raise ArgumentError, 'Options Hash is expected' if attributes.nil?

      if attributes[:key]
        unless attributes[:key].kind_of?(String)
          raise ArgumentError, ':key must be a String'
        end
      end

      if attributes[:mode]
        unless %(test live).include?(attributes[:mode].to_s)
          raise ArgumentError, ':mode must be set to live or test'
        end
      end

      if attributes[:value]
        unless is_numeric?(attributes[:value]) && attributes[:value].to_f > 0
          raise ArgumentError, ':value must be a positive numeric value representing the charge amount'
        end
      end

      if attributes[:version]
        unless is_numeric?(attributes[:version]) && attributes[:version].to_f > 0
          raise ArgumentError, ':version must be a positive numeric value representing API version to use'
        end
      end

      if attributes[:return_url]
        unless is_url?(attributes[:return_url])
          raise ArgumentError, ':return_url must be a valid URI format'
        end
      end

      if attributes[:cancel_url]
        unless is_url?(attributes[:cancel_url])
          raise ArgumentError, ':cancel_url must be a valid URI format'
        end
      end     
    
      if attributes[:webhook_url]
        unless is_url?(attributes[:webhook_url])
          raise ArgumentError, ':webhook_url must be a valid URI format'
        end
      end 
    end

    def get_resource_url(resource_name)
      case @api_version
      when 2
        "#{API_URL}/v:2:type:#{resource_name}"
      else
        API_URL
      end
    end

    def is_numeric?(str)
      Float(str) != nil rescue false
    end 

    def is_url?(uri)
        !!URI.parse(uri) rescue URI::InvalidURIError false
    end   

    def make_request(resource_name, options)
      options = options.merge({
        key: @options[:key],
        test: API_MODES.fetch(:"#{@options[:mode]}")
      }).freeze
      
      begin
        response = JSON.parse RestClient.get( get_resource_url(resource_name), { params: options } ), symbolize_names: true
      rescue RestClient::ExceptionWithResponse => e
        response = JSON.parse e.response, symbolize_names: true
      end

      data = response[:data]
      data[:code] = data.delete(:code) || data.delete(:error_code)
      data[:message] = data.delete(:description) || data.delete(:error_name)

      if response[:result] == 'error'
        raise Litepaid::Exception.new data[:message], :unprocessable_entity, data[:code]
      end

      data
    end       

  end
end