# frozen_string_literal: true

module InstagramGraphAPI
  class Client
    module Users
      DEFAULT_USER_FIELDS = %w[
        id
        username
        name
        account_type
        biography
        website
        profile_picture_url
        media_count
        followers_count
        follows_count
      ].join(',').freeze

      # GET /me?fields=...
      # Fetches the authenticated user (or another user by id when supplied).
      def user(id = 'me', fields: DEFAULT_USER_FIELDS)
        get(id.to_s, fields: fields)
      end

      # Alias for `user` with no id — mirrors the planned API surface.
      def me(fields: DEFAULT_USER_FIELDS)
        user('me', fields: fields)
      end
    end
  end
end
