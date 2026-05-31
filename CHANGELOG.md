# Changelog

## 1.1.0

- **Content Publishing API** (`Client::Publish`): low-level
  `create_media_container`, `publish_media_container`,
  `media_container_status` plus high-level `client.publish.single_image`,
  `carousel`, `reel`, `story` helpers that run the full
  container-create → poll-status → publish lifecycle and return a
  `PublishResult` struct exposing `container_id`, `media_id`, and
  `status` (`:published`, `:error`, `:timeout`).
- **Read surface expansion**:
  - `Client::Stories#user_stories` / `#stories` — 24-hour window.
  - `Client::Tagged#user_tagged_media` / `#tagged_media` — `/me/tags`.
  - `Client::Insights#media_insights` / `#user_insights` — per-post
    and account-level metrics. Accepts a metric String, Array, media-kind
    Symbol, or the `:account` sentinel (expands to the metric whitelist).
  - `Client::Comments#media_comments`, `#reply_to_media`,
    `#reply_to_comment`, `#comment_replies`.
  - `Client::Hashtags#hashtag_search`, `#hashtag_top_media`,
    `#hashtag_recent_media`.
- **`InstagramGraphAPI::Metrics`** — per-media-kind insight metric
  whitelist (`MEDIA_INSIGHT_METRICS`) and `ACCOUNT_INSIGHT_METRICS`,
  aligned with the Graph API v21 schema (deprecated names like
  `impressions`, `engagement`, `video_views` are intentionally absent).
- **`InstagramGraphAPI::Validators`** — `Image`, `Video`, `Carousel`
  surface IG publish constraints (JPEG, MP4/MOV, H.264/AAC, size, aspect
  ratio, duration, 2..10 children) and raise `ValidationError` with the
  full list of errors so callers can short-circuit before container
  creation.
- **`Error#headers`** now carries response headers; **`TooManyRequests`**
  exposes `#retry_after` (parsed from the `Retry-After` header) so
  callers can implement backoff.

## 1.0.0

- Renamed from `instagram_basic_display_api` to `instagram_graph_api`.
- Reimplemented `users` and `media` read modules against the Instagram Graph API
  (Meta retired Basic Display).
- Modernized HTTP stack: Faraday 2 (dropped `faraday_middleware`).
- Preserved public method signatures used by `linkmyphotos-rails`:
  - `Client#user`
  - `Client#user_recent_media`
  - `Client#media_item`
  - `Client#refresh_access_token`
- Added planned API surface aliases (`me`, `recent_media`, `media`) for the
  follow-up reads-Graph-switch phase.

Publish APIs and expanded read surfaces (stories, reels, tagged media,
insights, comments) land in 1.1.0 via phase 1b.
