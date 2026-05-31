# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::Hashtags do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }
  let(:hashtag_id) { '17841593000000000' }

  describe '#hashtag_search' do
    it 'returns the hashtag id' do
      stub_graph_get(
        'ig_hashtag_search',
        response_fixture: 'hashtags/search.json',
        query: { 'q' => 'california', 'user_id' => 'me' }
      )
      result = client.hashtag_search(query: 'california')
      expect(result.data.first.id).to eq(hashtag_id)
    end
  end

  describe '#hashtag_top_media' do
    it 'fetches top media for a hashtag' do
      stub_graph_get(
        "#{hashtag_id}/top_media",
        response_fixture: 'hashtags/top_media.json',
        query: { 'user_id' => 'me' }
      )
      result = client.hashtag_top_media(hashtag_id: hashtag_id)
      expect(result.data.length).to eq(2)
      expect(result.data.first.like_count).to eq(18211)
    end
  end

  describe '#hashtag_recent_media' do
    it 'GETs /{id}/recent_media' do
      stub = stub_graph_get(
        "#{hashtag_id}/recent_media",
        response_fixture: 'hashtags/top_media.json',
        query: { 'user_id' => 'me' }
      )
      client.hashtag_recent_media(hashtag_id: hashtag_id)
      expect(stub).to have_been_requested
    end
  end
end
