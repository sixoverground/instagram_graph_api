# frozen_string_literal: true

module InstagramGraphAPI
  class Client
    module AccessToken
      # GET /refresh_access_token?grant_type=ig_refresh_token&access_token=...
      # Long-lived token refresh (returns a new token good for ~60 days).
      def refresh_access_token
        get('refresh_access_token', grant_type: 'ig_refresh_token')
      end
    end
  end
end
