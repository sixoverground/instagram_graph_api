# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'webmock/rspec'
require 'instagram_graph_api'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    InstagramGraphAPI.reset
  end
end

def fixture_path
  File.expand_path('fixtures', __dir__)
end

def fixture(name)
  File.read(File.join(fixture_path, name), encoding: 'UTF-8')
end

def stub_graph_get(path, response_fixture:, status: 200, query: nil)
  url = "#{InstagramGraphAPI.api_url}/#{path}"
  matcher = query ? hash_including(query) : hash_including({})
  stub_request(:get, url)
    .with(query: matcher)
    .to_return(
      status: status,
      body: fixture(response_fixture),
      headers: { 'Content-Type' => 'application/json' }
    )
end
