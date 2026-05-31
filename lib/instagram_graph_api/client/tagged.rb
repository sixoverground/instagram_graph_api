# frozen_string_literal: true

module InstagramGraphAPI
  class Client
    # GET /{ig-user-id}/tags — media that have tagged this user.
    module Tagged
      DEFAULT_TAGGED_FIELDS = %w[
        id
        caption
        media_type
        media_url
        thumbnail_url
        permalink
        timestamp
        username
      ].join(',').freeze

      def user_tagged_media(ig_user_id: 'me', fields: DEFAULT_TAGGED_FIELDS, limit: 25, after: nil)
        get("#{ig_user_id}/tags", fields: fields, limit: limit, after: after)
      end

      def tagged_media(ig_user_id: 'me', fields: DEFAULT_TAGGED_FIELDS, limit: 25, after: nil)
        user_tagged_media(ig_user_id: ig_user_id, fields: fields, limit: limit, after: after)
      end
    end
  end
end
