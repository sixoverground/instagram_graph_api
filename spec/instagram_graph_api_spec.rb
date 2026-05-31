# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI do
  it 'has a version number' do
    expect(InstagramGraphAPI::VERSION).to eq('1.1.0')
  end

  describe '.client' do
    it 'returns a Client' do
      expect(InstagramGraphAPI.client).to be_a(InstagramGraphAPI::Client)
    end

    it 'passes options through to the client' do
      client = InstagramGraphAPI.client(access_token: 'IGAA-test')
      expect(client.access_token).to eq('IGAA-test')
    end
  end

  describe 'configuration' do
    it 'defaults to the Graph API host' do
      expect(InstagramGraphAPI.api_url).to eq('https://graph.instagram.com')
    end

    it 'allows configuration via block' do
      InstagramGraphAPI.configure { |c| c.access_token = 'IGAA-block' }
      expect(InstagramGraphAPI.access_token).to eq('IGAA-block')
    end

    it 'resets to defaults' do
      InstagramGraphAPI.access_token = 'tmp'
      InstagramGraphAPI.reset
      expect(InstagramGraphAPI.access_token).to be_nil
    end

    it 'exposes only the keys it actually uses' do
      expect(InstagramGraphAPI::Configuration::VALID_OPTIONS_KEYS)
        .to contain_exactly(:access_token, :api_url, :user_agent)
    end
  end
end
