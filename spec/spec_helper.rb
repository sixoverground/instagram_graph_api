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

def stub_graph_get(path, response_fixture: nil, response_body: nil, status: 200, query: nil, response_headers: {})
  url = "#{InstagramGraphAPI.api_url}/#{path}"
  matcher = query ? hash_including(query) : hash_including({})
  body = response_body || (response_fixture ? fixture(response_fixture) : '{}')
  stub_request(:get, url)
    .with(query: matcher)
    .to_return(
      status: status,
      body: body,
      headers: { 'Content-Type' => 'application/json' }.merge(response_headers)
    )
end

def stub_graph_post(path, response_fixture: nil, response_body: nil, status: 200, body_includes: nil, response_headers: {})
  url = "#{InstagramGraphAPI.api_url}/#{path}"
  body = response_body || (response_fixture ? fixture(response_fixture) : '{}')
  req = stub_request(:post, url)
  req = req.with(body: hash_including(body_includes)) if body_includes
  req.to_return(
    status: status,
    body: body,
    headers: { 'Content-Type' => 'application/json' }.merge(response_headers)
  )
end
