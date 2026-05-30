# Changelog

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
