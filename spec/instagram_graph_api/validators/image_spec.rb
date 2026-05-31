# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Validators::Image do
  describe '.validate' do
    it 'returns true for a valid JPEG URL with no metadata' do
      expect(described_class.validate('https://cdn.example.com/photo.jpg')).to be(true)
    end

    it 'returns true with valid size + aspect ratio metadata' do
      expect(described_class.validate(
        'https://cdn.example.com/photo.jpg',
        size_bytes:   4 * 1024 * 1024,
        aspect_ratio: 1.0
      )).to be(true)
    end

    it 'rejects non-http(s) URLs' do
      expect {
        described_class.validate('s3://bucket/key.jpg')
      }.to raise_error(InstagramGraphAPI::ValidationError, /image_url must be an http\(s\) URL/)
    end

    it 'rejects PNG' do
      expect {
        described_class.validate('https://cdn.example.com/photo.png')
      }.to raise_error(InstagramGraphAPI::ValidationError, /must be JPEG/)
    end

    it 'rejects oversized files' do
      expect {
        described_class.validate('https://cdn.example.com/photo.jpg', size_bytes: 9 * 1024 * 1024)
      }.to raise_error(InstagramGraphAPI::ValidationError, /<= 8388608 bytes/)
    end

    it 'rejects aspect ratios outside 0.8..1.91' do
      expect {
        described_class.validate('https://cdn.example.com/photo.jpg', aspect_ratio: 0.5)
      }.to raise_error(InstagramGraphAPI::ValidationError, /aspect ratio/)

      expect {
        described_class.validate('https://cdn.example.com/photo.jpg', aspect_ratio: 2.5)
      }.to raise_error(InstagramGraphAPI::ValidationError, /aspect ratio/)
    end

    it 'accepts explicit format that overrides the URL extension' do
      expect(described_class.validate('https://cdn.example.com/photo', format: 'jpg')).to be(true)
    end

    it 'coerces numeric strings (e.g. JSON params)' do
      expect(described_class.validate(
        'https://cdn.example.com/photo.jpg',
        size_bytes:   '4194304',
        aspect_ratio: '1.0'
      )).to be(true)
    end

    it 'collects (not raises) when size/aspect arrive as un-coercible strings' do
      expect {
        described_class.validate('https://cdn.example.com/photo.jpg', size_bytes: 'big', aspect_ratio: 'wide')
      }.to raise_error(InstagramGraphAPI::ValidationError) do |err|
        expect(err.errors).to include(a_string_matching(/size_bytes must be an integer/))
        expect(err.errors).to include(a_string_matching(/aspect_ratio must be a number/))
      end
    end

    it 'collects multiple errors into one ValidationError' do
      expect {
        described_class.validate('not-a-url', size_bytes: 10 * 1024 * 1024, aspect_ratio: 0.1)
      }.to raise_error(InstagramGraphAPI::ValidationError) do |err|
        expect(err.errors.length).to be >= 2
      end
    end
  end
end
