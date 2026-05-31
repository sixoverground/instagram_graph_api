# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::Tagged do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }

  describe '#user_tagged_media' do
    it 'fetches /me/tags by default' do
      stub_graph_get('me/tags', response_fixture: 'tagged.json')
      page = client.user_tagged_media
      expect(page.data.first.username).to eq('fanaccount')
      expect(page.paging.cursors.after).to eq('NEXT_CURSOR')
    end

    it 'passes limit + after through' do
      stub = stub_graph_get('me/tags', response_fixture: 'tagged.json',
                                       query: { 'limit' => '50', 'after' => 'CURSOR' })
      client.user_tagged_media(limit: 50, after: 'CURSOR')
      expect(stub).to have_been_requested
    end
  end

  describe '#tagged_media alias' do
    it 'matches user_tagged_media' do
      stub_graph_get('me/tags', response_fixture: 'tagged.json')
      expect(client.tagged_media.data.length).to eq(2)
    end
  end

  it 'raises Forbidden on 403' do
    stub_graph_get('me/tags', response_fixture: 'errors/403.json', status: 403)
    expect { client.user_tagged_media }.to raise_error(InstagramGraphAPI::Forbidden)
  end
end
