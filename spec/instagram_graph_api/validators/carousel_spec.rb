# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Validators::Carousel do
  let(:good) { 'https://cdn.example.com/img.jpg' }

  describe '.validate' do
    it 'accepts 2..10 valid children' do
      expect(described_class.validate([good, good])).to be(true)
      expect(described_class.validate([good] * 10)).to be(true)
    end

    it 'rejects fewer than 2 children' do
      expect {
        described_class.validate([good])
      }.to raise_error(InstagramGraphAPI::ValidationError, /at least 2 children/)
    end

    it 'rejects more than 10 children' do
      expect {
        described_class.validate([good] * 11)
      }.to raise_error(InstagramGraphAPI::ValidationError, /more than 10 children/)
    end

    it 'surfaces the index of any invalid child' do
      expect {
        described_class.validate([good, 'not-a-url', good])
      }.to raise_error(InstagramGraphAPI::ValidationError, /child 1: /)
    end
  end
end
