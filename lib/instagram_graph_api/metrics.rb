# frozen_string_literal: true

module InstagramGraphAPI
  # Whitelist of insight metric names the Instagram Graph API returns for
  # each media kind. Names that Meta retired during the 2024 and 2025
  # schema cleanups — `impressions`, `engagement`, `video_views`,
  # `plays` — are intentionally absent.
  #
  # A rejected name fails the whole request, not just its own column: the
  # API validates the metric list up front and answers 400 for all of it.
  # One retired name therefore costs every metric for that media kind, so
  # this list is only ever widened against a verified response.
  #
  # `plays` was dropped 2026-09-20. It had been kept on video and reel on
  # the belief that v21 still served it; production rejects it with
  # `metric[6] must be one of the following values: ...`, and that list
  # does not contain it. Video takes `views` in its place, verified
  # against a real feed video on the same call. The same error names
  # every metric the API will accept, and `exits` is absent from it too,
  # which is why the story set no longer asks for it.
  #
  # Consumed by the Rails ingestion layer in phase 5b.
  module Metrics
    MEDIA_INSIGHT_METRICS = {
      image:    %w[reach likes comments shares saved total_interactions].freeze,
      video:    %w[reach likes comments shares saved total_interactions views].freeze,
      reel:     %w[reach likes comments shares saved total_interactions views ig_reels_avg_watch_time ig_reels_video_view_total_time].freeze,
      # `navigation` is what replaced `exits`, but it reports through a
      # breakdown this client does not ask for yet, so it is left out
      # until a live story can be used to check the shape that comes back.
      story:    %w[reach replies views].freeze,
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
