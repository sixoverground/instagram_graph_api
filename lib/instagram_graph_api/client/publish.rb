# frozen_string_literal: true

module InstagramGraphAPI
  class Client
    # Instagram Graph API Content Publishing API.
    #
    # Two layers:
    #
    # * Low-level endpoints — `create_media_container`,
    #   `publish_media_container`, `media_container_status` — each one
    #   hits a single Graph endpoint and returns the raw `Hashie::Mash`
    #   response.
    #
    # * High-level helpers — `client.publish.single_image`,
    #   `client.publish.carousel`, `client.publish.reel`,
    #   `client.publish.story` — each runs the full container-create →
    #   poll-status → publish dance and returns a `PublishResult`.
    module Publish
      PublishResult = Struct.new(
        :container_id,
        :media_id,
        :status,
        :container_status,
        keyword_init: true
      )

      DEFAULT_POLL_INTERVAL_SECONDS = 2
      DEFAULT_POLL_TIMEOUT_SECONDS  = 300

      CONTAINER_STATUS_FIELDS = 'status_code,status'

      # POST /{ig-user-id}/media
      # Returns a `Hashie::Mash` with `.id` (the container id).
      def create_media_container(ig_user_id:, **params)
        post("#{ig_user_id}/media", params.compact)
      end

      # POST /{ig-user-id}/media_publish
      # Returns a `Hashie::Mash` with `.id` (the published media id).
      def publish_media_container(ig_user_id:, creation_id:)
        post("#{ig_user_id}/media_publish", creation_id: creation_id)
      end

      # GET /{ig-container-id}?fields=status_code,status
      # Returns a `Hashie::Mash` with `.status_code` (one of
      # `IN_PROGRESS`, `FINISHED`, `ERROR`, `EXPIRED`).
      def media_container_status(container_id:, fields: CONTAINER_STATUS_FIELDS)
        get(container_id.to_s, fields: fields)
      end

      # Returns the high-level publish helper facade.
      def publish
        @publish_helpers ||= Helpers.new(self)
      end

      class Helpers
        def initialize(client)
          @client = client
        end

        # Single-image post. Creates a container, polls until FINISHED,
        # then publishes. Returns a `PublishResult`.
        def single_image(ig_user_id:, image_url:, caption: nil, **opts)
          container = @client.create_media_container(
            ig_user_id: ig_user_id,
            image_url:  image_url,
            caption:    caption
          )
          complete(ig_user_id: ig_user_id, container_id: container.id, **opts)
        end

        # Carousel post (2..10 images). Creates one container per child
        # with `is_carousel_item=true`, then a `CAROUSEL` parent container
        # whose `children` is the child container id list. Polls + publishes
        # the parent.
        def carousel(ig_user_id:, child_image_urls:, caption: nil, **opts)
          child_ids = child_image_urls.map do |url|
            child = @client.create_media_container(
              ig_user_id:       ig_user_id,
              image_url:        url,
              is_carousel_item: true
            )
            child.id
          end

          parent = @client.create_media_container(
            ig_user_id: ig_user_id,
            media_type: 'CAROUSEL',
            children:   child_ids.join(','),
            caption:    caption
          )
          complete(ig_user_id: ig_user_id, container_id: parent.id, **opts)
        end

        # Reel post. `share_to_feed` mirrors the IG default; set false to
        # keep the reel out of the grid.
        def reel(ig_user_id:, video_url:, caption: nil, cover_url: nil, share_to_feed: true, **opts)
          container = @client.create_media_container(
            ig_user_id:    ig_user_id,
            media_type:    'REELS',
            video_url:     video_url,
            caption:       caption,
            cover_url:     cover_url,
            share_to_feed: share_to_feed
          )
          complete(ig_user_id: ig_user_id, container_id: container.id, **opts)
        end

        # Story post. Pass exactly one of `image_url` or `video_url`.
        def story(ig_user_id:, image_url: nil, video_url: nil, **opts)
          raise ArgumentError, 'story requires exactly one of image_url or video_url' if image_url.nil? == video_url.nil?

          params = { ig_user_id: ig_user_id, media_type: 'STORIES' }
          params[:image_url] = image_url if image_url
          params[:video_url] = video_url if video_url

          container = @client.create_media_container(**params)
          complete(ig_user_id: ig_user_id, container_id: container.id, **opts)
        end

        private

        def complete(ig_user_id:, container_id:, poll: true, poll_interval: DEFAULT_POLL_INTERVAL_SECONDS, poll_timeout: DEFAULT_POLL_TIMEOUT_SECONDS)
          if poll
            status = wait_for_status(container_id, interval: poll_interval, timeout: poll_timeout)
            return PublishResult.new(container_id: container_id, media_id: nil, status: :timeout, container_status: status) if status == 'IN_PROGRESS'
            return PublishResult.new(container_id: container_id, media_id: nil, status: :error,   container_status: status) unless status == 'FINISHED'
          end

          response = @client.publish_media_container(ig_user_id: ig_user_id, creation_id: container_id)
          PublishResult.new(
            container_id:     container_id,
            media_id:         response.id,
            status:           :published,
            container_status: 'PUBLISHED'
          )
        end

        def wait_for_status(container_id, interval:, timeout:)
          deadline = monotonic + timeout
          loop do
            status = @client.media_container_status(container_id: container_id).status_code
            return status unless status == 'IN_PROGRESS'
            return status if monotonic >= deadline

            sleep interval
          end
        end

        def monotonic
          Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end
      end
    end
  end
end
