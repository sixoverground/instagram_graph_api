# frozen_string_literal: true

module InstagramGraphAPI
  class Error < StandardError
    attr_reader :http_status, :payload

    def initialize(message = nil, http_status: nil, payload: nil)
      super(message)
      @http_status = http_status
      @payload     = payload
    end
  end

  class BadRequest          < Error; end
  class Unauthorized        < Error; end
  class Forbidden           < Error; end
  class NotFound            < Error; end
  class TooManyRequests     < Error; end
  class InternalServerError < Error; end
  class BadGateway          < Error; end
  class ServiceUnavailable  < Error; end
  class GatewayTimeout      < Error; end
end
