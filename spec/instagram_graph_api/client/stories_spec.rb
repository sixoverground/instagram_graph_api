# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::Stories do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }

  describe '#user_stories' do
    it 'fetches /me/stories by default' do
      stub_graph_get('me/stories', response_fixture: 'stories.json')
      page = client.user_stories
      expect(page.data).to be_an(Array)
      expect(page.data.first.media_type).to eq('IMAGE')
      expect(page.data.last.thumbnail_url).to include('story_vid1_thumb.jpg')
    end

    it 'fetches stories for a specific ig_user_id' do
      stub = stub_graph_get('17841400000000000/stories', response_fixture: 'stories.json')
      client.user_stories(ig_user_id: '17841400000000000')
      expect(stub).to have_been_requested
    end

    it 'passes the fields list through' do
      stub = stub_graph_get('me/stories', response_fixture: 'stories.json',
                                          query: { 'fields' => 'id,media_url' })
      client.user_stories(fields: 'id,media_url')
      expect(stub).to have_been_requested
    end
  end

  describe '#stories alias' do
    it 'matches user_stories' do
      stub_graph_get('me/stories', response_fixture: 'stories.json')
      expect(client.stories.data.length).to eq(2)
    end
  end

  it 'raises NotFound on 404' do
    stub_graph_get('me/stories', response_fixture: 'errors/404.json', status: 404)
    expect { client.user_stories }.to raise_error(InstagramGraphAPI::NotFound)
  end
end
