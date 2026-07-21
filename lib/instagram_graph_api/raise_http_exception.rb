# frozen_string_literal: true

require 'faraday'
require 'json'

module InstagramGraphAPI
  class RaiseHttpException < Faraday::Middleware
    # Meta returns expired / invalid / revoked access-token errors as an
    # OAuthException with code 190, frequently over HTTP 400 rather than 401.
    # We surface those as Unauthorized so callers can rescue the correct class
    # regardless of Meta's inconsistent status code.
    OAUTH_ACCESS_TOKEN_ERROR_CODE = 190

    def on_complete(env)
      status = env[:status]
      return if status.between?(200, 299)

      payload = parse_body(env[:body])
      message = extract_message(payload, status)
      headers = normalize_headers(env[:response_headers])

      raise exception_class(status, payload)
        .new(message, http_status: status, payload: payload, headers: headers)
    end

    private

    def exception_class(status, payload)
      return InstagramGraphAPI::Unauthorized if access_token_error?(payload)

      case status
      when 400 then InstagramGraphAPI::BadRequest
      when 401 then InstagramGraphAPI::Unauthorized
      when 403 then InstagramGraphAPI::Forbidden
      when 404 then InstagramGraphAPI::NotFound
      when 429 then InstagramGraphAPI::TooManyRequests
      when 500 then InstagramGraphAPI::InternalServerError
      when 502 then InstagramGraphAPI::BadGateway
      when 503 then InstagramGraphAPI::ServiceUnavailable
      when 504 then InstagramGraphAPI::GatewayTimeout
      else InstagramGraphAPI::Error
      end
    end

    def access_token_error?(payload)
      err = payload.is_a?(Hash) ? payload['error'] : nil
      err.is_a?(Hash) && err['code'] == OAUTH_ACCESS_TOKEN_ERROR_CODE
    end

    def parse_body(body)
      return body if body.is_a?(Hash)
      return {} if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      { 'raw' => body.to_s }
    end

    def extract_message(payload, status)
      err = payload.is_a?(Hash) ? payload['error'] : nil
      return "HTTP #{status}" unless err.is_a?(Hash)

      [err['message'], err['code'] && "code=#{err['code']}", err['type'] && "type=#{err['type']}"]
        .compact.join(' ')
    end

    def normalize_headers(raw)
      return {} unless raw

      raw.each_with_object({}) { |(k, v), acc| acc[k.to_s.downcase] = v }
    end
  end
end

Faraday::Response.register_middleware(raise_http_exception: InstagramGraphAPI::RaiseHttpException)
