# frozen_string_literal: true

module InstagramGraphAPI
  class Client
    # GET /{ig-user-id}/stories — the 24-hour window of active stories
    # for a Business/Creator account.
    module Stories
      DEFAULT_STORY_FIELDS = %w[
        id
        media_type
        media_url
        thumbnail_url
        permalink
        timestamp
      ].join(',').freeze

      def user_stories(ig_user_id: 'me', fields: DEFAULT_STORY_FIELDS)
        get("#{ig_user_id}/stories", fields: fields)
      end

      def stories(ig_user_id: 'me', fields: DEFAULT_STORY_FIELDS)
        user_stories(ig_user_id: ig_user_id, fields: fields)
      end
    end
  end
end
