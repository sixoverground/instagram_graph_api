# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::AccessToken do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-current') }

  describe '#refresh_access_token' do
    it 'exchanges a long-lived token for a fresh one' do
      stub_graph_get('refresh_access_token', response_fixture: 'refresh_token.json',
                                             query: { 'grant_type' => 'ig_refresh_token' })

      response = client.refresh_access_token

      expect(response).to be_a(Hashie::Mash)
      expect(response.access_token).to start_with('IGAA')
      expect(response.token_type).to eq('bearer')
      expect(response.expires_in).to be > 0
    end

    it 'raises Unauthorized when the current token is invalid' do
      stub_graph_get('refresh_access_token', response_fixture: 'errors/401.json', status: 401)
      expect { client.refresh_access_token }.to raise_error(InstagramGraphAPI::Unauthorized)
    end
  end
end
