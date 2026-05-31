# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::Publish do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }
  let(:ig_user_id) { '17841400000000000' }
  let(:container_id) { '18000000000000001' }

  before do
    # Helpers sleep between polls — keep specs fast.
    allow_any_instance_of(InstagramGraphAPI::Client::Publish::Helpers).to receive(:sleep)
  end

  describe '#create_media_container' do
    it 'POSTs to /{ig-user-id}/media and returns the container id' do
      stub_graph_post("#{ig_user_id}/media", response_fixture: 'publish/create_container.json',
                                             body_includes: { 'image_url' => 'https://cdn.example.com/img.jpg' })
      result = client.create_media_container(ig_user_id: ig_user_id, image_url: 'https://cdn.example.com/img.jpg')
      expect(result.id).to eq('18000000000000001')
    end

    it 'drops nil params' do
      stub = stub_graph_post("#{ig_user_id}/media", response_fixture: 'publish/create_container.json')
      client.create_media_container(ig_user_id: ig_user_id, image_url: 'https://cdn.example.com/img.jpg', caption: nil)
      expect(stub).to have_been_requested
    end
  end

  describe '#publish_media_container' do
    it 'POSTs to /{ig-user-id}/media_publish with creation_id and returns the media id' do
      stub_graph_post("#{ig_user_id}/media_publish", response_fixture: 'publish/publish_response.json',
                                                    body_includes: { 'creation_id' => container_id })
      result = client.publish_media_container(ig_user_id: ig_user_id, creation_id: container_id)
      expect(result.id).to eq('17900000000000099')
    end
  end

  describe '#media_container_status' do
    it 'GETs /{container-id}?fields=status_code,status' do
      stub_graph_get(container_id, response_fixture: 'publish/container_finished.json',
                                   query: { 'fields' => 'status_code,status' })
      result = client.media_container_status(container_id: container_id)
      expect(result.status_code).to eq('FINISHED')
    end
  end

  describe 'high-level publish helpers' do
    describe '#publish.single_image' do
      it 'creates a container, polls until FINISHED, then publishes' do
        stub_graph_post("#{ig_user_id}/media", response_fixture: 'publish/create_container.json')
        stub_graph_get(container_id, response_fixture: 'publish/container_finished.json')
        stub_graph_post("#{ig_user_id}/media_publish", response_fixture: 'publish/publish_response.json',
                                                      body_includes: { 'creation_id' => container_id })

        result = client.publish.single_image(
          ig_user_id: ig_user_id,
          image_url:  'https://cdn.example.com/img.jpg',
          caption:    'hello world'
        )

        expect(result).to be_a(InstagramGraphAPI::Client::Publish::PublishResult)
        expect(result.container_id).to eq(container_id)
        expect(result.media_id).to eq('17900000000000099')
        expect(result.status).to eq(:published)
      end

      it 'waits through IN_PROGRESS then FINISHED' do
        stub_graph_post("#{ig_user_id}/media", response_fixture: 'publish/create_container.json')
        stub_request(:get, "#{InstagramGraphAPI.api_url}/#{container_id}")
          .with(query: hash_including({}))
          .to_return(
            { status: 200, body: fixture('publish/container_in_progress.json'), headers: { 'Content-Type' => 'application/json' } },
            { status: 200, body: fixture('publish/container_in_progress.json'), headers: { 'Content-Type' => 'application/json' } },
            { status: 200, body: fixture('publish/container_finished.json'),    headers: { 'Content-Type' => 'application/json' } }
          )
        stub_graph_post("#{ig_user_id}/media_publish", response_fixture: 'publish/publish_response.json')

        result = client.publish.single_image(ig_user_id: ig_user_id, image_url: 'https://cdn.example.com/img.jpg')
        expect(result.status).to eq(:published)
      end

      it 'returns :error when the container reports ERROR' do
        stub_graph_post("#{ig_user_id}/media", response_fixture: 'publish/create_container.json')
        stub_graph_get(container_id, response_fixture: 'publish/container_error.json')

        result = client.publish.single_image(ig_user_id: ig_user_id, image_url: 'https://cdn.example.com/img.jpg')
        expect(result.status).to eq(:error)
        expect(result.media_id).to be_nil
        expect(result.container_status).to eq('ERROR')
      end

      it 'returns :timeout when the container stays IN_PROGRESS past the deadline' do
        stub_graph_post("#{ig_user_id}/media", response_fixture: 'publish/create_container.json')
        stub_graph_get(container_id, response_fixture: 'publish/container_in_progress.json')

        result = client.publish.single_image(
          ig_user_id:    ig_user_id,
          image_url:     'https://cdn.example.com/img.jpg',
          poll_interval: 0,
          poll_timeout:  0
        )
        expect(result.status).to eq(:timeout)
        expect(result.container_status).to eq('IN_PROGRESS')
      end

      it 'skips polling when poll: false' do
        stub_graph_post("#{ig_user_id}/media", response_fixture: 'publish/create_container.json')
        publish_stub = stub_graph_post("#{ig_user_id}/media_publish", response_fixture: 'publish/publish_response.json')

        result = client.publish.single_image(
          ig_user_id: ig_user_id,
          image_url:  'https://cdn.example.com/img.jpg',
          poll:       false
        )
        expect(publish_stub).to have_been_requested
        expect(result.status).to eq(:published)
      end
    end

    describe '#publish.carousel' do
      it 'creates one container per child + parent CAROUSEL container, polls, publishes' do
        stub_request(:post, "#{InstagramGraphAPI.api_url}/#{ig_user_id}/media")
          .to_return(
            { status: 200, body: fixture('publish/create_child_container_1.json'), headers: { 'Content-Type' => 'application/json' } },
            { status: 200, body: fixture('publish/create_child_container_2.json'), headers: { 'Content-Type' => 'application/json' } },
            { status: 200, body: fixture('publish/create_container.json'),         headers: { 'Content-Type' => 'application/json' } }
          )
        stub_graph_get(container_id, response_fixture: 'publish/container_finished.json')
        stub_graph_post("#{ig_user_id}/media_publish", response_fixture: 'publish/publish_response.json')

        result = client.publish.carousel(
          ig_user_id:       ig_user_id,
          child_image_urls: ['https://cdn.example.com/1.jpg', 'https://cdn.example.com/2.jpg'],
          caption:          'carousel post'
        )

        expect(result.status).to eq(:published)
        expect(result.media_id).to eq('17900000000000099')
      end
    end

    describe '#publish.reel' do
      it 'creates a REELS container with the supplied params' do
        stub = stub_graph_post(
          "#{ig_user_id}/media",
          response_fixture: 'publish/create_container.json',
          body_includes: { 'media_type' => 'REELS', 'video_url' => 'https://cdn.example.com/reel.mp4' }
        )
        stub_graph_get(container_id, response_fixture: 'publish/container_finished.json')
        stub_graph_post("#{ig_user_id}/media_publish", response_fixture: 'publish/publish_response.json')

        client.publish.reel(ig_user_id: ig_user_id, video_url: 'https://cdn.example.com/reel.mp4')
        expect(stub).to have_been_requested
      end
    end

    describe '#publish.story' do
      it 'creates a STORIES container for an image story' do
        stub = stub_graph_post(
          "#{ig_user_id}/media",
          response_fixture: 'publish/create_container.json',
          body_includes: { 'media_type' => 'STORIES', 'image_url' => 'https://cdn.example.com/s.jpg' }
        )
        stub_graph_get(container_id, response_fixture: 'publish/container_finished.json')
        stub_graph_post("#{ig_user_id}/media_publish", response_fixture: 'publish/publish_response.json')

        client.publish.story(ig_user_id: ig_user_id, image_url: 'https://cdn.example.com/s.jpg')
        expect(stub).to have_been_requested
      end

      it 'raises when neither image_url nor video_url is given' do
        expect { client.publish.story(ig_user_id: ig_user_id) }.to raise_error(ArgumentError)
      end

      it 'raises when both image_url and video_url are given' do
        expect {
          client.publish.story(
            ig_user_id: ig_user_id,
            image_url:  'https://cdn.example.com/s.jpg',
            video_url:  'https://cdn.example.com/s.mp4'
          )
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'rate-limit handling on publish endpoints' do
    it 'raises TooManyRequests on 429 and exposes Retry-After' do
      stub_graph_post("#{ig_user_id}/media",
                      response_fixture: 'errors/429_with_retry_after.json',
                      status: 429,
                      response_headers: { 'Retry-After' => '60' })

      expect {
        client.create_media_container(ig_user_id: ig_user_id, image_url: 'https://cdn.example.com/img.jpg')
      }.to raise_error(InstagramGraphAPI::TooManyRequests) do |err|
        expect(err.retry_after).to eq(60)
      end
    end
  end
end
