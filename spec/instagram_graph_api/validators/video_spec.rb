# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Validators::Video do
  describe '.validate' do
    it 'returns true for a valid MP4 reel with reasonable metadata' do
      expect(described_class.validate(
        'https://cdn.example.com/reel.mp4',
        kind:             :reel,
        size_bytes:       40 * 1024 * 1024,
        duration_seconds: 30
      )).to be(true)
    end

    it 'rejects unknown kinds' do
      expect {
        described_class.validate('https://cdn.example.com/reel.mp4', kind: :tiktok)
      }.to raise_error(ArgumentError, /unknown video kind/)
    end

    it 'rejects non-MP4/MOV containers' do
      expect {
        described_class.validate('https://cdn.example.com/reel.webm', kind: :reel)
      }.to raise_error(InstagramGraphAPI::ValidationError, /MP4 or MOV/)
    end

    it 'rejects non-H264 video codecs' do
      expect {
        described_class.validate('https://cdn.example.com/reel.mp4', kind: :reel, video_codec: 'vp9')
      }.to raise_error(InstagramGraphAPI::ValidationError, /codec must be H\.264/)
    end

    it 'rejects non-AAC audio codecs' do
      expect {
        described_class.validate('https://cdn.example.com/reel.mp4', kind: :reel, audio_codec: 'opus')
      }.to raise_error(InstagramGraphAPI::ValidationError, /codec must be AAC/)
    end

    it 'rejects files larger than 100 MB' do
      expect {
        described_class.validate('https://cdn.example.com/reel.mp4', kind: :reel, size_bytes: 200 * 1024 * 1024)
      }.to raise_error(InstagramGraphAPI::ValidationError, /<= 104857600 bytes/)
    end

    it 'rejects reels longer than 90s' do
      expect {
        described_class.validate('https://cdn.example.com/reel.mp4', kind: :reel, duration_seconds: 120)
      }.to raise_error(InstagramGraphAPI::ValidationError, /<= 90s/)
    end

    it 'rejects feed videos longer than 60s' do
      expect {
        described_class.validate('https://cdn.example.com/v.mp4', kind: :feed, duration_seconds: 120)
      }.to raise_error(InstagramGraphAPI::ValidationError, /<= 60s/)
    end

    it 'coerces numeric strings (e.g. JSON params)' do
      expect(described_class.validate(
        'https://cdn.example.com/reel.mp4',
        kind:             :reel,
        size_bytes:       '41943040',
        duration_seconds: '30.5'
      )).to be(true)
    end

    it 'collects (not raises) when size/duration arrive as un-coercible strings' do
      expect {
        described_class.validate('https://cdn.example.com/reel.mp4', kind: :reel, size_bytes: 'big', duration_seconds: 'long')
      }.to raise_error(InstagramGraphAPI::ValidationError) do |err|
        expect(err.errors).to include(a_string_matching(/size_bytes must be a number/))
        expect(err.errors).to include(a_string_matching(/duration_seconds must be a number/))
      end
    end

    it 'rejects story videos longer than 60s' do
      expect {
        described_class.validate('https://cdn.example.com/s.mp4', kind: :story, duration_seconds: 90)
      }.to raise_error(InstagramGraphAPI::ValidationError, /<= 60s/)
    end
  end
end
