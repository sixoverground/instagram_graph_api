# frozen_string_literal: true

require 'instagram_graph_api/version'
require 'instagram_graph_api/configuration'
require 'instagram_graph_api/error'
require 'instagram_graph_api/api'
require 'instagram_graph_api/client'

module InstagramGraphAPI
  extend Configuration

  def self.client(options = {})
    InstagramGraphAPI::Client.new(options)
  end

  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)

    client.send(method, *args, &block)
  end

  def self.respond_to_missing?(method, include_private = false)
    client.respond_to?(method, include_private) || super
  end
end
