# frozen_string_literal: true

require 'faraday'
require 'instagram_graph_api/raise_http_exception'

module InstagramGraphAPI
  module Connection
    private

    def connection
      @connection ||= Faraday.new(
        url: api_url,
        headers: {
          'Accept'     => 'application/json',
          'User-Agent' => user_agent
        }
      ) do |conn|
        conn.request :url_encoded
        conn.response :raise_http_exception
        conn.response :json
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
