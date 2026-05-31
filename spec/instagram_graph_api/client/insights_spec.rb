# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::Insights do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }
  let(:media_id) { '17841405822304914' }
  let(:ig_user_id) { '17841400000000000' }

  describe '#media_insights' do
    it 'accepts a String metric list' do
      stub = stub_graph_get("#{media_id}/insights",
                            response_fixture: 'insights/media_insights.json',
                            query: { 'metric' => 'reach,likes,comments' })
      client.media_insights(media_id: media_id, metric: 'reach,likes,comments')
      expect(stub).to have_been_requested
    end

    it 'accepts an Array metric and joins it' do
      stub = stub_graph_get("#{media_id}/insights",
                            response_fixture: 'insights/media_insights.json',
                            query: { 'metric' => 'reach,likes' })
      client.media_insights(media_id: media_id, metric: %w[reach likes])
      expect(stub).to have_been_requested
    end

    it 'accepts a media-kind Symbol and expands to the per-kind whitelist' do
      stub = stub_graph_get(
        "#{media_id}/insights",
        response_fixture: 'insights/media_insights.json',
        query: { 'metric' => InstagramGraphAPI::Metrics::MEDIA_INSIGHT_METRICS[:image].join(',') }
      )
      client.media_insights(media_id: media_id, metric: :image)
      expect(stub).to have_been_requested
    end

    it 'returns the parsed response' do
      stub_graph_get("#{media_id}/insights", response_fixture: 'insights/media_insights.json')
      response = client.media_insights(media_id: media_id, metric: :image)
      names = response.data.map(&:name)
      expect(names).to include('reach', 'likes', 'comments', 'shares', 'saved', 'total_interactions')
    end

    it 'raises ArgumentError on an unknown media-kind Symbol' do
      expect {
        client.media_insights(media_id: media_id, metric: :unicorn)
      }.to raise_error(ArgumentError, /unknown media kind/)
    end
  end

  describe '#user_insights' do
    it 'accepts the :account sentinel' do
      stub = stub_graph_get(
        "#{ig_user_id}/insights",
        response_fixture: 'insights/account_insights.json',
        query: { 'metric' => InstagramGraphAPI::Metrics::ACCOUNT_INSIGHT_METRICS.join(','), 'period' => 'day' }
      )
      client.user_insights(ig_user_id: ig_user_id, metric: :account)
      expect(stub).to have_been_requested
    end

    it 'translates until_at to the IG `until` query param' do
      stub = stub_graph_get(
        "#{ig_user_id}/insights",
        response_fixture: 'insights/account_insights.json',
        query: { 'metric' => 'views', 'period' => 'day', 'since' => '1717113600', 'until' => '1717200000' }
      )
      client.user_insights(ig_user_id: ig_user_id, metric: 'views', since: '1717113600', until_at: '1717200000')
      expect(stub).to have_been_requested
    end

    it 'defaults ig_user_id to me' do
      stub = stub_graph_get('me/insights', response_fixture: 'insights/account_insights.json')
      client.user_insights(metric: :account)
      expect(stub).to have_been_requested
    end
  end
end
