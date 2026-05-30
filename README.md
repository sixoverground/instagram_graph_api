# instagram_graph_api

A Ruby client for the Instagram Graph API, supporting Business and Creator
accounts. Successor to `instagram_basic_display_api` (Meta retired Basic
Display in late 2024).

## Installation

Add to your `Gemfile`:

```ruby
gem 'instagram_graph_api', git: 'https://github.com/sixoverground/instagram_graph_api.git', tag: 'v1.0.0'
```

Then run `bundle install`.

## Usage

```ruby
client = InstagramGraphAPI.client(access_token: 'IGAA...')

# Fetch the authenticated user
me = client.user(fields: 'id,username,name,account_type,media_count,followers_count')
me.username           # => "snoopdog"
me.account_type       # => "BUSINESS"

# Fetch a page of the user's media
page = client.user_recent_media(limit: 25)
page.data.each { |media| puts media.permalink }
next_after = page.paging&.cursors&.after

# Fetch a single media item by id
item = client.media_item('17841405822304914')
item.media_type       # => "IMAGE" / "VIDEO" / "CAROUSEL_ALBUM"

# Refresh a long-lived token (good for ~60 days)
fresh = client.refresh_access_token
fresh.access_token    # => "IGAA..."
fresh.expires_in      # => 5183944
```

## Public method surface (phase 1a — reads only)

| Method | Signature | Notes |
| --- | --- | --- |
| `Client#user` | `(id = 'me', fields:)` → `Hashie::Mash` | `id` defaults to `me`; pass an IG user id to look up another user (limited by Graph permissions). |
| `Client#me` | `(fields:)` → `Hashie::Mash` | Alias for `user('me', fields:)`. |
| `Client#user_recent_media` | `(limit:, after:, fields:)` → `Hashie::Mash` with `.data` + `.paging` | Paged. |
| `Client#recent_media` | `(limit:, after:, fields:)` → `Hashie::Mash` | Alias for `user_recent_media`. |
| `Client#media_item` | `(id, fields:)` → `Hashie::Mash` | Positional `id`. |
| `Client#media` | `(id:, fields:)` → `Hashie::Mash` | Keyword `id:`. Alias for `media_item`. |
| `Client#refresh_access_token` | `()` → `Hashie::Mash` with `.access_token` | Long-lived token refresh. |

Errors raised on non-2xx responses:

`InstagramGraphAPI::BadRequest` (400), `Unauthorized` (401), `Forbidden` (403),
`NotFound` (404), `TooManyRequests` (429), `InternalServerError` (500),
`BadGateway` (502), `ServiceUnavailable` (503), `GatewayTimeout` (504).

## What's deferred

Publish (single image, carousel, video, reels, stories), stories/reels/tagged
reads, insights, comments + replies — all land in **1.1.0** via phase 1b of
the multi-repo instagram-publishing project. See
[`linkmyphotos-rails/docs/plans/instagram-publishing/phase-1b-gem-publish.md`](https://github.com/sixoverground/linkmyphotos-rails/blob/main/docs/plans/instagram-publishing/phase-1b-gem-publish.md).

## Development

```bash
bundle install
bundle exec rspec
```

Specs use WebMock with JSON fixtures captured against a sandbox Business
account; no network calls are made in CI.

## License

MIT. See `LICENSE.txt`.
