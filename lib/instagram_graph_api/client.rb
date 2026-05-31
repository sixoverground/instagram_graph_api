# frozen_string_literal: true

require 'instagram_graph_api/api'

module InstagramGraphAPI
  class Client < API
  end
end

require 'instagram_graph_api/client/access_token'
require 'instagram_graph_api/client/media'
require 'instagram_graph_api/client/users'
require 'instagram_graph_api/client/publish'
require 'instagram_graph_api/client/stories'
require 'instagram_graph_api/client/tagged'
require 'instagram_graph_api/client/insights'
require 'instagram_graph_api/client/comments'
require 'instagram_graph_api/client/hashtags'

module InstagramGraphAPI
  class Client
    include AccessToken
    include Media
    include Users
    include Publish
    include Stories
    include Tagged
    include Insights
    include Comments
    include Hashtags
  end
end
