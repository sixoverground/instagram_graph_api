# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::Users do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }

  describe '#user' do
    it 'fetches the authenticated user from /me' do
      stub_graph_get('me', response_fixture: 'user.json')

      user = client.user

      expect(user).to be_a(Hashie::Mash)
      expect(user.username).to eq('snoopdog')
      expect(user.account_type).to eq('BUSINESS')
      expect(user.media_count).to eq(842)
      expect(user.followers_count).to eq(20_500_000)
    end

    it 'passes through the requested fields' do
      stub = stub_graph_get('me', response_fixture: 'user.json',
                                  query: { 'fields' => 'id,username' })
      client.user(fields: 'id,username')
      expect(stub).to have_been_requested
    end

    it 'fetches a specific user by id when supplied' do
      stub_graph_get('17841400000000000', response_fixture: 'user.json')
      user = client.user('17841400000000000')
      expect(user.id).to eq('17841400000000000')
    end
  end

  describe '#me' do
    it 'is an alias for user(\'me\')' do
      stub_graph_get('me', response_fixture: 'user.json')
      expect(client.me.username).to eq('snoopdog')
    end
  end

  describe 'error handling' do
    {
      400 => InstagramGraphAPI::BadRequest,
      401 => InstagramGraphAPI::Unauthorized,
      403 => InstagramGraphAPI::Forbidden,
      429 => InstagramGraphAPI::TooManyRequests,
      500 => InstagramGraphAPI::InternalServerError
    }.each do |status, error_class|
      it "raises #{error_class} on HTTP #{status}" do
        stub_graph_get('me', response_fixture: "errors/#{status}.json", status: status)
        expect { client.user }.to raise_error(error_class)
      end
    end
  end
end
