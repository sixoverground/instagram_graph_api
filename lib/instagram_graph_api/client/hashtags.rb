# frozen_string_literal: true

module InstagramGraphAPI
  class Client
    # GET /ig_hashtag_search, GET /{ig-hashtag-id}/top_media,
    # GET /{ig-hashtag-id}/recent_media — hashtag lookup + performance.
    module Hashtags
      DEFAULT_HASHTAG_MEDIA_FIELDS = %w[
        id
        media_type
        permalink
        timestamp
        caption
        like_count
        comments_count
      ].join(',').freeze

      # GET /ig_hashtag_search?user_id=...&q=...
      def hashtag_search(query:, user_id: 'me')
        get('ig_hashtag_search', user_id: user_id, q: query)
      end

      # GET /{ig-hashtag-id}/top_media?user_id=...&fields=...
      def hashtag_top_media(hashtag_id:, user_id: 'me', fields: DEFAULT_HASHTAG_MEDIA_FIELDS, limit: 25)
        get("#{hashtag_id}/top_media", user_id: user_id, fields: fields, limit: limit)
      end

      # GET /{ig-hashtag-id}/recent_media?user_id=...&fields=...
      def hashtag_recent_media(hashtag_id:, user_id: 'me', fields: DEFAULT_HASHTAG_MEDIA_FIELDS, limit: 25)
        get("#{hashtag_id}/recent_media", user_id: user_id, fields: fields, limit: limit)
      end
    end
  end
end
