# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Metrics do
  describe 'MEDIA_INSIGHT_METRICS' do
    it 'covers every media kind the publisher can create' do
      expect(described_class::MEDIA_INSIGHT_METRICS.keys).to match_array(%i[image video reel story carousel])
    end

    it 'includes the lifetime engagement metrics on feed media' do
      %i[image video carousel].each do |kind|
        expect(described_class::MEDIA_INSIGHT_METRICS[kind]).to include('reach', 'likes', 'comments', 'shares', 'saved', 'total_interactions')
      end
    end

    it 'includes reel-specific watch-time metrics' do
      expect(described_class::MEDIA_INSIGHT_METRICS[:reel]).to include('ig_reels_avg_watch_time', 'ig_reels_video_view_total_time', 'views')
    end

    it 'uses story-specific metrics' do
      expect(described_class::MEDIA_INSIGHT_METRICS[:story]).to match_array(%w[reach replies exits views])
    end

    it 'excludes metrics deprecated in the 2024-2025 Graph schema' do
      all_metrics = described_class::MEDIA_INSIGHT_METRICS.values.flatten.uniq
      expect(all_metrics).not_to include('impressions') # retired across all media kinds
      expect(all_metrics).not_to include('engagement')  # retired
      expect(all_metrics).not_to include('video_views') # renamed → `views`/`plays`
    end

    it 'keeps `plays` on the kinds where Graph v21 still supports it' do
      expect(described_class::MEDIA_INSIGHT_METRICS[:video]).to include('plays')
      expect(described_class::MEDIA_INSIGHT_METRICS[:reel]).to include('plays')
      %i[image story carousel].each do |kind|
        expect(described_class::MEDIA_INSIGHT_METRICS[kind]).not_to include('plays')
      end
    end
  end

  describe 'ACCOUNT_INSIGHT_METRICS' do
    it 'covers the account-level v1 must-haves from the master plan' do
      expect(described_class::ACCOUNT_INSIGHT_METRICS).to include(
        'views', 'profile_views', 'follower_count', 'accounts_engaged',
        'total_interactions', 'reach', 'likes', 'comments', 'shares', 'saves'
      )
    end
  end

  describe '.metrics_for' do
    it 'accepts symbols and strings' do
      expect(described_class.metrics_for(:image)).to eq(described_class::MEDIA_INSIGHT_METRICS[:image])
      expect(described_class.metrics_for('reel')).to eq(described_class::MEDIA_INSIGHT_METRICS[:reel])
    end

    it 'raises ArgumentError for unknown kinds' do
      expect { described_class.metrics_for(:tiktok) }.to raise_error(ArgumentError, /unknown media kind/)
    end
  end
end
