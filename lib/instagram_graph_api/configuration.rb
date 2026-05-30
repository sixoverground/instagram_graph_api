# frozen_string_literal: true

module InstagramGraphAPI
  module Configuration
    VALID_OPTIONS_KEYS = %i[
      access_token
      api_url
      api_version
      user_agent
    ].freeze

    DEFAULT_ACCESS_TOKEN = nil
    DEFAULT_API_URL      = 'https://graph.instagram.com'
    DEFAULT_API_VERSION  = 'v23.0'
    DEFAULT_USER_AGENT   = "InstagramGraphAPI Ruby Gem #{InstagramGraphAPI::VERSION}"

    attr_accessor(*VALID_OPTIONS_KEYS)

    def self.extended(base)
      base.reset
    end

    def configure
      yield self
      self
    end

    def options
      VALID_OPTIONS_KEYS.each_with_object({}) { |k, h| h[k] = send(k) }
    end

    def reset
      self.access_token = DEFAULT_ACCESS_TOKEN
      self.api_url      = DEFAULT_API_URL
      self.api_version  = DEFAULT_API_VERSION
      self.user_agent   = DEFAULT_USER_AGENT
      self
    end
  end
end
