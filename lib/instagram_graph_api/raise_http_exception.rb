# frozen_string_literal: true

require 'faraday'
require 'json'

module InstagramGraphAPI
  class RaiseHttpException < Faraday::Middleware
    def on_complete(env)
      status = env[:status]
      return if status.between?(200, 299)

      payload = parse_body(env[:body])
      message = extract_message(payload, status)
      headers = normalize_headers(env[:response_headers])

      case status
      when 400 then raise InstagramGraphAPI::BadRequest.new(message, http_status: status, payload: payload, headers: headers)
      when 401 then raise InstagramGraphAPI::Unauthorized.new(message, http_status: status, payload: payload, headers: headers)
      when 403 then raise InstagramGraphAPI::Forbidden.new(message, http_status: status, payload: payload, headers: headers)
      when 404 then raise InstagramGraphAPI::NotFound.new(message, http_status: status, payload: payload, headers: headers)
      when 429 then raise InstagramGraphAPI::TooManyRequests.new(message, http_status: status, payload: payload, headers: headers)
      when 500 then raise InstagramGraphAPI::InternalServerError.new(message, http_status: status, payload: payload, headers: headers)
      when 502 then raise InstagramGraphAPI::BadGateway.new(message, http_status: status, payload: payload, headers: headers)
      when 503 then raise InstagramGraphAPI::ServiceUnavailable.new(message, http_status: status, payload: payload, headers: headers)
      when 504 then raise InstagramGraphAPI::GatewayTimeout.new(message, http_status: status, payload: payload, headers: headers)
      else
        raise InstagramGraphAPI::Error.new(message, http_status: status, payload: payload, headers: headers)
      end
    end

    private

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
