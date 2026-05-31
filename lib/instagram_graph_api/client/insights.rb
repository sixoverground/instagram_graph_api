# frozen_string_literal: true

require 'instagram_graph_api/metrics'

module InstagramGraphAPI
  class Client
    # GET /{ig-media-id}/insights and GET /{ig-user-id}/insights —
    # per-post and account-level metrics. The full metric whitelist
    # lives in `InstagramGraphAPI::Metrics`.
    module Insights
      # GET /{ig-media-id}/insights?metric=...
      #
      # `metric` accepts a String (comma-separated), an Array of metric
      # names, or a Symbol media-kind (`:image`/`:video`/`:reel`/
      # `:story`/`:carousel`) which expands to the full per-kind metric
      # set from `Metrics::MEDIA_INSIGHT_METRICS`.
      def media_insights(media_id:, metric:)
        get("#{media_id}/insights", metric: serialize_metric(metric))
      end

      # GET /{ig-user-id}/insights?metric=...&period=...
      #
      # `metric` accepts the same shapes as `media_insights`, plus the
      # sentinel `:account` which expands to `Metrics::ACCOUNT_INSIGHT_METRICS`.
      def user_insights(metric:, ig_user_id: 'me', period: 'day', since: nil, until_at: nil, metric_type: nil, breakdown: nil, timeframe: nil)
        params = {
          metric:      serialize_metric(metric),
          period:      period,
          since:       since,
          until:       until_at,
          metric_type: metric_type,
          breakdown:   breakdown,
          timeframe:   timeframe
        }.compact

        get("#{ig_user_id}/insights", **params)
      end

      private

      def serialize_metric(metric)
        case metric
        when String then metric
        when Array  then metric.join(',')
        when :account
          Metrics::ACCOUNT_INSIGHT_METRICS.join(',')
        when Symbol
          Metrics.metrics_for(metric).join(',')
        else
          raise ArgumentError, "metric must be a String, Array, or media-kind Symbol (got #{metric.inspect})"
        end
      end
    end
  end
end
