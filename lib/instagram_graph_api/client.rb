# frozen_string_literal: true

require 'instagram_graph_api/api'

module InstagramGraphAPI
  class Client < API
  end
end

require 'instagram_graph_api/client/access_token'
require 'instagram_graph_api/client/media'
require 'instagram_graph_api/client/users'

module InstagramGraphAPI
  class Client
    include AccessToken
    include Media
    include Users
  end
end
