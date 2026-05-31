# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::RaiseHttpException do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }

  it 'passes response headers through to TooManyRequests for Retry-After parsing' do
    stub_graph_get('me',
                   response_fixture: 'errors/429_with_retry_after.json',
                   status: 429,
                   response_headers: { 'Retry-After' => '120' })

    expect { client.user }.to raise_error(InstagramGraphAPI::TooManyRequests) do |err|
      expect(err.headers['retry-after']).to eq('120')
      expect(err.retry_after).to eq(120)
      expect(err.http_status).to eq(429)
      expect(err.payload['error']['code']).to eq(4)
    end
  end

  it 'returns nil from #retry_after when no header is present' do
    stub_graph_get('me', response_fixture: 'errors/429.json', status: 429)
    expect { client.user }.to raise_error(InstagramGraphAPI::TooManyRequests) do |err|
      expect(err.retry_after).to be_nil
    end
  end

  it 'returns nil from #retry_after when the header value cannot be coerced to an Integer' do
    err = InstagramGraphAPI::TooManyRequests.new('rate limited', http_status: 429, headers: { 'retry-after' => [] })
    expect(err.retry_after).to be_nil
  end
end
