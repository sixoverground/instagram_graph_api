# frozen_string_literal: true

module InstagramGraphAPI
  module Validators
    # Validates a video asset against Instagram Graph API publish
    # constraints for the requested surface (`:feed`, `:reel`, `:story`).
    # The gem does not transcode or probe — callers pass duration and
    # size as metadata.
    module Video
      ALLOWED_FORMATS = %w[mp4 mov].freeze
      MAX_SIZE_BYTES  = 100 * 1024 * 1024 # 100 MB (all kinds)

      KIND_LIMITS = {
        feed:  { max_duration_seconds: 60,  label: 'feed video' },
        reel:  { max_duration_seconds: 90,  label: 'reel' },
        story: { max_duration_seconds: 60,  label: 'story video' }
      }.freeze

      def self.validate(url, kind:, size_bytes: nil, duration_seconds: nil, format: nil, video_codec: nil, audio_codec: nil)
        kind_sym = kind.to_s.downcase.to_sym
        limits = KIND_LIMITS[kind_sym]
        raise ArgumentError, "unknown video kind: #{kind.inspect} (allowed: #{KIND_LIMITS.keys.inspect})" unless limits

        errors = []

        unless url.is_a?(String) && url.match?(%r{\Ahttps?://})
          errors << 'video_url must be an http(s) URL'
        end

        inferred_format = format || infer_format(url)
        if inferred_format && !ALLOWED_FORMATS.include?(inferred_format.to_s.downcase)
          errors << "video must be MP4 or MOV (got #{inferred_format})"
        end

        if video_codec && video_codec.to_s.downcase != 'h264'
          errors << "video codec must be H.264 (got #{video_codec})"
        end

        if audio_codec && audio_codec.to_s.downcase != 'aac'
          errors << "audio codec must be AAC (got #{audio_codec})"
        end

        if size_bytes && size_bytes > MAX_SIZE_BYTES
          errors << "#{limits[:label]} must be <= #{MAX_SIZE_BYTES} bytes (got #{size_bytes})"
        end

        if duration_seconds && duration_seconds > limits[:max_duration_seconds]
          errors << "#{limits[:label]} must be <= #{limits[:max_duration_seconds]}s (got #{duration_seconds})"
        end

        return true if errors.empty?

        raise InstagramGraphAPI::ValidationError.new(errors.join('; '), errors: errors)
      end

      def self.infer_format(url)
        return nil unless url.is_a?(String)

        ext = File.extname(url.split('?').first.to_s).delete('.').downcase
        ext.empty? ? nil : ext
      end
    end
  end
end
