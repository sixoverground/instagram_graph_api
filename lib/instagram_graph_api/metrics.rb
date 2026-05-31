# frozen_string_literal: true

module InstagramGraphAPI
  # Whitelist of insight metric names the Instagram Graph API (v21+)
  # returns for each media kind. Names that Meta retired during the 2024
  # and 2025 schema cleanups — `impressions`, `engagement`,
  # `video_views` — are intentionally absent. `plays` is still supported
  # for feed videos and reels in v21+ and is included accordingly.
  #
  # Consumed by the Rails ingestion layer in phase 5b.
  module Metrics
    MEDIA_INSIGHT_METRICS = {
      image:    %w[reach likes comments shares saved total_interactions].freeze,
      video:    %w[reach likes comments shares saved total_interactions plays].freeze,
      reel:     %w[reach likes comments shares saved total_interactions plays views ig_reels_avg_watch_time ig_reels_video_view_total_time].freeze,
      story:    %w[reach replies exits views].freeze,
      carousel: %w[reach likes comments shares saved total_interactions views].freeze
    }.freeze

    ACCOUNT_INSIGHT_METRICS = %w[
      views
      profile_views
      follower_count
      accounts_engaged
      total_interactions
      reach
      likes
      comments
      shares
      saves
    ].freeze

    def self.metrics_for(media_kind)
      key = media_kind.to_s.downcase.to_sym
      MEDIA_INSIGHT_METRICS.fetch(key) do
        raise ArgumentError, "unknown media kind: #{media_kind.inspect} (allowed: #{MEDIA_INSIGHT_METRICS.keys.inspect})"
      end
    end
  end
end
