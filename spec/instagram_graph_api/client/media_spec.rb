# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::Media do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }

  describe '#user_recent_media' do
    it 'fetches the authenticated user\'s media list' do
      stub_graph_get('me/media', response_fixture: 'recent_media.json')

      page = client.user_recent_media(limit: 25)

      expect(page).to be_a(Hashie::Mash)
      expect(page.data).to be_an(Array)
      expect(page.data.first.media_type).to eq('IMAGE')
      expect(page.data.first.permalink).to start_with('https://www.instagram.com/')
    end

    it 'exposes the after cursor for pagination' do
      stub_graph_get('me/media', response_fixture: 'recent_media.json')
      page = client.user_recent_media(limit: 25)
      expect(page.paging.cursors.after).to eq('QVFIUm9Ka1NhTUF2Ym1DSGFsZA')
    end

    it 'passes limit + after through to the API' do
      stub = stub_graph_get('me/media', response_fixture: 'recent_media.json',
                                        query: { 'limit' => '5', 'after' => 'CURSOR' })
      client.user_recent_media(limit: 5, after: 'CURSOR')
      expect(stub).to have_been_requested
    end
  end

  describe '#recent_media (alias)' do
    it 'returns the same shape as user_recent_media' do
      stub_graph_get('me/media', response_fixture: 'recent_media.json')
      page = client.recent_media(limit: 25)
      expect(page.data).to be_an(Array)
    end
  end

  describe '#media_item' do
    it 'fetches a single media by id' do
      stub_graph_get('17841405822304914', response_fixture: 'media.json')

      item = client.media_item('17841405822304914')

      expect(item.id).to eq('17841405822304914')
      expect(item.media_type).to eq('CAROUSEL_ALBUM')
      expect(item.caption).to include('drop')
    end

    it 'raises NotFound on 404' do
      stub_graph_get('bogus_id', response_fixture: 'errors/404.json', status: 404)
      expect { client.media_item('bogus_id') }.to raise_error(InstagramGraphAPI::NotFound)
    end
  end

  describe '#media (alias)' do
    it 'accepts id as a keyword argument' do
      stub_graph_get('17841405822304914', response_fixture: 'media.json')
      item = client.media(id: '17841405822304914')
      expect(item.id).to eq('17841405822304914')
    end
  end
end
