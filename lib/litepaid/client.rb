require 'uri'
require 'json'
require 'rest_client'

module Litepaid
	class Client
		API_URL = 'https://www.litepaid.com/api'
		INVOICE_URL = 'https://www.litepaid.com/invoice'		
		API_MODES = {
			live: 0,
			test: 1
		}.freeze

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
      	end

		# required: id
		def check_payment(options)
			ensure_valid_attributes options
			ensure_presence_of_attributes %w(id), options
			response = make_request('check-invoice-status', options)
			data = response[:data]

			{ 
				code: data[:code] || data[:error_code], 
				message: data[:description] || data[:error_name], 
				status: response[:result] == 'success' ? :ok : :unprocessable_entity 
			}
		end      	

      	# required: value, return_url
      	# optional: cancel_url, currency, webhook_url, description
		def create_payment(options)
			ensure_valid_attributes options
			ensure_presence_of_attributes %w(value return_url), options
			response = make_request('create-invoice', options)

			data = response[:data]
			code = data[:code] || data[:error_code]
			message = data[:description] || data[:error_name]

			if response[:result] == 'success'				
				token = data[:invoice_token]
				payment_url = "#{INVOICE_URL}/id:#{token}"
				{ token: token, payment_url: payment_url, code: code, message: message, status: :ok }
			else
				{ code: code, message: message, status: :unprocessable_entity }
			end
		end

		# required: id, address
		def refund_payment(options)
			ensure_valid_attributes options
			ensure_presence_of_attributes %w(id address), options
			response = make_request('refund', options)

			data = response[:data]

			{ 
				code: data[:code] || data[:error_code], 
				message: data[:description] || data[:error_name], 
				status: response[:result] == 'success' ? :ok : :unprocessable_entity 
			}			
		end


		private

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
			response = JSON.parse RestClient.get( get_resource_url(resource_name), { params: options } )

			response.with_indifferent_access
		end				

	end
end