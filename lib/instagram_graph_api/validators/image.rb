# frozen_string_literal: true

module InstagramGraphAPI
  module Validators
    # Validates an image asset against Instagram Graph API publish
    # constraints. Callers pass whatever metadata they already have;
    # the validator checks only what it was given (the gem does not
    # fetch remote URLs).
    module Image
      MAX_SIZE_BYTES   = 8 * 1024 * 1024 # 8 MB
      MIN_ASPECT_RATIO = 0.8             # 4:5
      MAX_ASPECT_RATIO = 1.91            # 1.91:1
      ALLOWED_FORMATS  = %w[jpg jpeg].freeze

      def self.validate(url, size_bytes: nil, aspect_ratio: nil, format: nil)
        errors = []

        unless url.is_a?(String) && url.match?(%r{\Ahttps?://})
          errors << 'image_url must be an http(s) URL'
        end

        inferred_format = format || infer_format(url)
        if inferred_format && !ALLOWED_FORMATS.include?(inferred_format.to_s.downcase)
          errors << "image must be JPEG (got #{inferred_format})"
        end

        coerced_size = coerce_integer(size_bytes, label: 'size_bytes', errors: errors)
        if coerced_size && coerced_size > MAX_SIZE_BYTES
          errors << "image must be <= #{MAX_SIZE_BYTES} bytes (got #{coerced_size})"
        end

        coerced_ratio = coerce_float(aspect_ratio, label: 'aspect_ratio', errors: errors)
        if coerced_ratio && (coerced_ratio < MIN_ASPECT_RATIO || coerced_ratio > MAX_ASPECT_RATIO)
          errors << "image aspect ratio must be between #{MIN_ASPECT_RATIO} and #{MAX_ASPECT_RATIO} (got #{coerced_ratio})"
        end

        return true if errors.empty?

        raise InstagramGraphAPI::ValidationError.new(errors.join('; '), errors: errors)
      end

      def self.infer_format(url)
        return nil unless url.is_a?(String)

        ext = File.extname(url.split('?').first.to_s).delete('.').downcase
        ext.empty? ? nil : ext
      end

      def self.coerce_integer(value, label:, errors:)
        return nil if value.nil?

        Integer(value)
      rescue ArgumentError, TypeError
        errors << "#{label} must be an integer (got #{value.inspect})"
        nil
      end

      def self.coerce_float(value, label:, errors:)
        return nil if value.nil?

        Float(value)
      rescue ArgumentError, TypeError
        errors << "#{label} must be a number (got #{value.inspect})"
        nil
      end
    end
  end
end
