# frozen_string_literal: true

module InstagramGraphAPI
  class Client
    module Media
      DEFAULT_MEDIA_FIELDS = %w[
        id
        caption
        media_type
        media_url
        thumbnail_url
        permalink
        timestamp
        username
      ].join(',').freeze

      # GET /me/media?fields=...&limit=...&after=...
      # Paged list of the authenticated user's media.
      def user_recent_media(limit: 25, after: nil, fields: DEFAULT_MEDIA_FIELDS)
        get('me/media', fields: fields, limit: limit, after: after)
      end

      # Alias matching the planned API table (used by future phase 5a).
      def recent_media(limit: 25, after: nil, fields: DEFAULT_MEDIA_FIELDS)
        user_recent_media(limit: limit, after: after, fields: fields)
      end

      # GET /{media-id}?fields=...
      def media_item(id, fields: DEFAULT_MEDIA_FIELDS)
        get(id.to_s, fields: fields)
      end

      # Alias matching the planned API table.
      def media(id:, fields: DEFAULT_MEDIA_FIELDS)
        media_item(id, fields: fields)
      end
    end
  end
end
