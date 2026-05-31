# frozen_string_literal: true

require 'spec_helper'

RSpec.describe InstagramGraphAPI::Client::Comments do
  let(:client) { InstagramGraphAPI.client(access_token: 'IGAA-test') }
  let(:media_id)   { '17841405822304914' }
  let(:comment_id) { '17865000000000002' }

  describe '#media_comments' do
    it 'fetches comments for a media' do
      stub_graph_get("#{media_id}/comments", response_fixture: 'comments/comments.json')
      page = client.media_comments(media_id: media_id)
      expect(page.data.length).to eq(2)
      expect(page.data.first.text).to eq('🔥🔥🔥')
      expect(page.paging.cursors.after).to eq('NEXT')
    end

    it 'passes limit + after through' do
      stub = stub_graph_get(
        "#{media_id}/comments",
        response_fixture: 'comments/comments.json',
        query: { 'limit' => '10', 'after' => 'CURSOR' }
      )
      client.media_comments(media_id: media_id, limit: 10, after: 'CURSOR')
      expect(stub).to have_been_requested
    end
  end

  describe '#reply_to_comment' do
    it 'POSTs to /{comment-id}/replies and returns the new comment id' do
      stub_graph_post("#{comment_id}/replies",
                      response_fixture: 'comments/reply.json',
                      body_includes: { 'message' => 'thanks!' })
      result = client.reply_to_comment(comment_id: comment_id, message: 'thanks!')
      expect(result.id).to eq('17865000000000099')
    end
  end

  describe '#reply_to_media' do
    it 'POSTs to /{media-id}/replies' do
      stub = stub_graph_post("#{media_id}/replies",
                             response_fixture: 'comments/reply.json',
                             body_includes: { 'message' => 'thanks all!' })
      client.reply_to_media(media_id: media_id, message: 'thanks all!')
      expect(stub).to have_been_requested
    end
  end

  describe '#comment_replies' do
    it 'fetches replies for a comment' do
      stub_graph_get("#{comment_id}/replies", response_fixture: 'comments/replies.json')
      result = client.comment_replies(comment_id: comment_id)
      expect(result.data.first.username).to eq('snoopdog')
    end
  end

  it 'raises Unauthorized on 401' do
    stub_graph_get("#{media_id}/comments", response_fixture: 'errors/401.json', status: 401)
    expect { client.media_comments(media_id: media_id) }.to raise_error(InstagramGraphAPI::Unauthorized)
  end
end
