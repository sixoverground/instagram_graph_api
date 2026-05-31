# frozen_string_literal: true

module InstagramGraphAPI
  class Error < StandardError
    attr_reader :http_status, :payload, :headers

    def initialize(message = nil, http_status: nil, payload: nil, headers: nil)
      super(message)
      @http_status = http_status
      @payload     = payload
      @headers     = headers || {}
    end
  end

  class BadRequest          < Error; end
  class Unauthorized        < Error; end
  class Forbidden           < Error; end
  class NotFound            < Error; end

  class TooManyRequests < Error
    # Seconds the caller should wait before retrying, parsed from the
    # standard `Retry-After` response header. Returns nil when the
    # header is missing or non-numeric.
    def retry_after
      raw = headers['retry-after'] || headers['Retry-After']
      Integer(raw) if raw
    rescue ArgumentError
      nil
    end
  end

  class InternalServerError < Error; end
  class BadGateway          < Error; end
  class ServiceUnavailable  < Error; end
  class GatewayTimeout      < Error; end

  class ValidationError < Error
    def initialize(message = nil, errors: [])
      super(message)
      @errors = Array(errors)
    end

    attr_reader :errors
  end
end
