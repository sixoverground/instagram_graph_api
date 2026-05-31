# frozen_string_literal: true

module InstagramGraphAPI
  class Client
    # GET /{ig-media-id}/comments, POST /{ig-media-id}/replies,
    # GET /{comment-id}/replies — read comments on a media and reply
    # to / read replies on a comment.
    module Comments
      DEFAULT_COMMENT_FIELDS = %w[
        id
        text
        username
        timestamp
        like_count
        hidden
        replies
      ].join(',').freeze

      def media_comments(media_id:, fields: DEFAULT_COMMENT_FIELDS, limit: 50, after: nil)
        get("#{media_id}/comments", fields: fields, limit: limit, after: after)
      end

      # POST /{ig-media-id}/replies — top-level reply to a media.
      def reply_to_media(media_id:, message:)
        post("#{media_id}/replies", message: message)
      end

      # POST /{comment-id}/replies — threaded reply to a comment.
      def reply_to_comment(comment_id:, message:)
        post("#{comment_id}/replies", message: message)
      end

      def comment_replies(comment_id:, fields: DEFAULT_COMMENT_FIELDS, limit: 50, after: nil)
        get("#{comment_id}/replies", fields: fields, limit: limit, after: after)
      end
    end
  end
end
