# instagram_graph_api

A Ruby client for the Instagram Graph API, supporting Business and Creator
accounts. Successor to `instagram_basic_display_api` (Meta retired Basic
Display in late 2024).

## Installation

Add to your `Gemfile`:

```ruby
gem 'instagram_graph_api', git: 'https://github.com/sixoverground/instagram_graph_api.git', tag: 'v1.1.0'
```

Then run `bundle install`.

## Usage

```ruby
client = InstagramGraphAPI.client(access_token: 'IGAA...')
```

### Users

```ruby
me = client.user(fields: 'id,username,name,account_type,media_count,followers_count')
me.username           # => "snoopdog"
me.account_type       # => "BUSINESS"
```

### Media (reads)

```ruby
page = client.user_recent_media(limit: 25)
page.data.each { |media| puts media.permalink }
next_after = page.paging&.cursors&.after

item = client.media_item('17841405822304914')
item.media_type       # => "IMAGE" / "VIDEO" / "CAROUSEL_ALBUM" / "REELS"
```

### Publishing

High-level helpers run the full container-create → poll-status →
publish lifecycle and return a `PublishResult` struct:

```ruby
result = client.publish.single_image(
  ig_user_id: '17841400000000000',
  image_url:  'https://cdn.example.com/photo.jpg',
  caption:    'hello world'
)
result.status        # => :published
result.media_id      # => "17900..."
result.container_id  # => "18000..."

client.publish.carousel(
  ig_user_id:       '17841400000000000',
  child_image_urls: ['https://.../1.jpg', 'https://.../2.jpg', 'https://.../3.jpg'],
  caption:          'carousel'
)

client.publish.reel(
  ig_user_id:    '17841400000000000',
  video_url:     'https://cdn.example.com/reel.mp4',
  caption:       'new reel',
  share_to_feed: true
)

client.publish.story(
  ig_user_id: '17841400000000000',
  image_url:  'https://cdn.example.com/story.jpg'
)
```

Each helper accepts these polling controls:

| Option | Default | Notes |
| --- | --- | --- |
| `poll:` | `true` | When `false`, publishes immediately without checking container status. |
| `poll_interval:` | `2` | Seconds between status polls. |
| `poll_timeout:` | `300` | Seconds before giving up; result returns `status: :timeout`. |

If the container reports `ERROR`, the helper returns `status: :error`.

Drop down to the low-level endpoints whenever the helper is too
opinionated:

```ruby
container = client.create_media_container(ig_user_id: ..., image_url: ..., caption: ...)
client.media_container_status(container_id: container.id).status_code
client.publish_media_container(ig_user_id: ..., creation_id: container.id)
```

### Stories, tagged media, hashtags

```ruby
client.user_stories                                # /me/stories
client.user_tagged_media(limit: 25)                # /me/tags
client.hashtag_search(query: 'california')         # /ig_hashtag_search
client.hashtag_top_media(hashtag_id: '17841...')   # /{id}/top_media
client.hashtag_recent_media(hashtag_id: '17841...')# /{id}/recent_media
```

### Insights

```ruby
# per-post — Symbol shorthand expands to the per-kind whitelist
client.media_insights(media_id: '17841...', metric: :reel)
client.media_insights(media_id: '17841...', metric: %w[reach likes saved])

# account-level — :account expands to the full account metric whitelist
client.user_insights(metric: :account, period: 'day')
client.user_insights(ig_user_id: '17841...', metric: 'views', since: '...', until_at: '...')
```

The metric whitelist lives in `InstagramGraphAPI::Metrics`:

```ruby
InstagramGraphAPI::Metrics::MEDIA_INSIGHT_METRICS[:reel]
# => ["reach", "likes", "comments", "shares", "saved", "total_interactions",
#     "plays", "views", "ig_reels_avg_watch_time", "ig_reels_video_view_total_time"]

InstagramGraphAPI::Metrics::ACCOUNT_INSIGHT_METRICS
# => ["views", "profile_views", "follower_count", "accounts_engaged",
#     "total_interactions", "reach", "likes", "comments", "shares", "saves"]
```

Deprecated names (`impressions`, `engagement`, `video_views`) are
intentionally absent — the Graph v21 schema renamed/retired them in
2024–2025.

### Comments + replies

```ruby
client.media_comments(media_id: '17841...')                          # GET comments
client.reply_to_media(media_id: '17841...', message: 'thanks all!')  # top-level reply
client.reply_to_comment(comment_id: '17865...', message: 'thanks!')  # threaded reply
client.comment_replies(comment_id: '17865...')                       # read replies
```

### Token refresh

```ruby
fresh = client.refresh_access_token
fresh.access_token    # => "IGAA..."
fresh.expires_in      # => 5183944
```

### Validators (pre-flight checks)

Validate locally before burning a container quota:

```ruby
InstagramGraphAPI::Validators::Image.validate(
  'https://cdn.example.com/photo.jpg',
  size_bytes:   4 * 1024 * 1024,
  aspect_ratio: 1.0
)

InstagramGraphAPI::Validators::Video.validate(
  'https://cdn.example.com/reel.mp4',
  kind:             :reel,
  size_bytes:       40 * 1024 * 1024,
  duration_seconds: 45,
  video_codec:      'h264',
  audio_codec:      'aac'
)

InstagramGraphAPI::Validators::Carousel.validate([
  'https://cdn.example.com/1.jpg',
  'https://cdn.example.com/2.jpg'
])
```

The validators only check metadata the caller supplies — the gem does
not fetch remote URLs. On failure they raise
`InstagramGraphAPI::ValidationError` whose `#errors` is the full list of
issues found.

### Errors and rate limiting

Non-2xx responses raise per-status exception classes:

| Status | Class |
| --- | --- |
| 400 | `BadRequest` |
| 401 | `Unauthorized` |
| 403 | `Forbidden` |
| 404 | `NotFound` |
| 429 | `TooManyRequests` (`#retry_after` parses the `Retry-After` header) |
| 500 | `InternalServerError` |
| 502 | `BadGateway` |
| 503 | `ServiceUnavailable` |
| 504 | `GatewayTimeout` |

Each carries `#http_status`, `#payload` (the parsed JSON body) and
`#headers` (downcased response headers).

```ruby
begin
  client.user_recent_media
rescue InstagramGraphAPI::TooManyRequests => e
  sleep(e.retry_after || 60)
  retry
end
```

## Public method surface

| Method | Notes |
| --- | --- |
| `Client#user` / `#me` | Read profile. |
| `Client#user_recent_media` / `#recent_media` / `#media_item` / `#media` | Read media. |
| `Client#refresh_access_token` | Long-lived token refresh. |
| `Client#create_media_container` / `#publish_media_container` / `#media_container_status` | Publish lifecycle (low-level). |
| `Client#publish.single_image` / `.carousel` / `.reel` / `.story` | Publish lifecycle (high-level). |
| `Client#user_stories` / `#stories` | Stories. |
| `Client#user_tagged_media` / `#tagged_media` | Tagged media. |
| `Client#media_insights` / `#user_insights` | Insights. |
| `Client#media_comments` / `#reply_to_media` / `#reply_to_comment` / `#comment_replies` | Comments + replies. |
| `Client#hashtag_search` / `#hashtag_top_media` / `#hashtag_recent_media` | Hashtags. |

## Development

```bash
bundle install
bundle exec rspec
```

Specs use WebMock with JSON fixtures captured against a sandbox Business
account; no network calls are made in CI.

## License

MIT. See `LICENSE.txt`.
