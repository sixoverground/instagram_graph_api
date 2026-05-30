# frozen_string_literal: true

require 'faraday'
require 'instagram_graph_api/raise_http_exception'

module InstagramGraphAPI
  module Connection
    private

    def connection
      options = {
        headers: {
          'Accept'     => 'application/json',
          'User-Agent' => user_agent
        },
        url: api_url
      }

      Faraday.new(options) do |conn|
        conn.request :url_encoded
        conn.response :raise_http_exception
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
