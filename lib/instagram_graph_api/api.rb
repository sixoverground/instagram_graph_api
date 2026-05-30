# frozen_string_literal: true

require 'hashie'
require 'instagram_graph_api/configuration'
require 'instagram_graph_api/connection'

module InstagramGraphAPI
  class API
    include Connection

    attr_accessor(*Configuration::VALID_OPTIONS_KEYS)

    def initialize(options = {})
      options = InstagramGraphAPI.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    def get(path, params = {})
      params = { access_token: access_token }.merge(params).compact
      response = connection.get(path, params)
      wrap(response.body)
    end

    def post(path, params = {})
      params = { access_token: access_token }.merge(params).compact
      response = connection.post(path, params)
      wrap(response.body)
    end

    def delete(path, params = {})
      params = { access_token: access_token }.merge(params).compact
      response = connection.delete(path, params)
      wrap(response.body)
    end

    private

    def wrap(body)
      case body
      when Hash  then Hashie::Mash.new(body)
      when Array then body.map { |item| item.is_a?(Hash) ? Hashie::Mash.new(item) : item }
      else body
      end
    end
  end
end
