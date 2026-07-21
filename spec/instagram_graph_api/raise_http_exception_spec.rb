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

  it 'raises Unauthorized for an OAuthException code=190 returned over HTTP 400' do
    stub_graph_get('me', response_fixture: 'errors/400_oauth_190.json', status: 400)

    expect { client.user }.to raise_error(InstagramGraphAPI::Unauthorized) do |err|
      expect(err.http_status).to eq(400)
      expect(err.code).to eq(190)
    end
  end

  it 'raises BadRequest for a non-token HTTP 400 (e.g. code=100 object missing)' do
    stub_graph_get('me', response_fixture: 'errors/400.json', status: 400)

    expect { client.user }.to raise_error(InstagramGraphAPI::BadRequest) do |err|
      expect(err.code).to eq(100)
    end
  end

  it 'raises Unauthorized for a plain HTTP 401' do
    stub_graph_get('me', response_fixture: 'errors/401.json', status: 401)
    expect { client.user }.to raise_error(InstagramGraphAPI::Unauthorized)
  end

  it 'exposes #code and #error_subcode from the payload' do
    err = InstagramGraphAPI::BadRequest.new(
      'boom', http_status: 400,
      payload: { 'error' => { 'code' => 100, 'error_subcode' => 33 } }
    )
    expect(err.code).to eq(100)
    expect(err.error_subcode).to eq(33)

    expect(InstagramGraphAPI::Error.new('no body').code).to be_nil
  end
end
