# frozen_string_literal: true

require 'instagram_graph_api/validators/image'

module InstagramGraphAPI
  module Validators
    # Validates a carousel's child URLs. Each child is run through the
    # image validator. Children counts outside Instagram's documented
    # 2..10 range are rejected.
    module Carousel
      MIN_CHILDREN = 2
      MAX_CHILDREN = 10

      def self.validate(child_urls)
        errors = []
        child_urls = Array(child_urls)

        if child_urls.length < MIN_CHILDREN
          errors << "carousel requires at least #{MIN_CHILDREN} children (got #{child_urls.length})"
        elsif child_urls.length > MAX_CHILDREN
          errors << "carousel cannot have more than #{MAX_CHILDREN} children (got #{child_urls.length})"
        end

        child_urls.each_with_index do |url, idx|
          Validators::Image.validate(url)
        rescue InstagramGraphAPI::ValidationError => e
          errors << "child #{idx}: #{e.message}"
        end

        return true if errors.empty?

        raise InstagramGraphAPI::ValidationError.new(errors.join('; '), errors: errors)
      end
    end
  end
end
