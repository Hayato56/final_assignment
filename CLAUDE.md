# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyDiscogsApp — a vinyl record collection manager built with Rails 7.1.6. Users catalog their records with details like OBI presence and cleaning history, and can auto-populate metadata/cover art via the Discogs API.

**Stack:** Ruby 3.1.4, Rails 7.1.6, PostgreSQL 15, Tailwind CSS 4, Hotwire (Turbo + Stimulus), Devise, Docker Compose

## Development Commands

### Start the app (Docker)
```bash
docker compose up
```

### Start without Docker (local development)
```bash
bin/dev   # Runs Procfile.dev: Rails server + JS/CSS watchers via Foreman
```

### Database
```bash
bin/rails db:create db:migrate
bin/rails db:migrate          # Run pending migrations
bin/rails db:rollback         # Rollback last migration
```

### Tests
```bash
bin/rails test                          # Run all tests
bin/rails test test/models/post_test.rb # Run a single test file
bin/rails test:system                   # Run system tests (Selenium/Capybara)
```

### Linting / Assets
```bash
bin/rails tailwindcss:build   # One-time CSS build
```

## Architecture

### Core Domain

The app has two models:
- **User** — Devise-authenticated. `has_many :posts, dependent: :destroy`
- **Post** — A record in the collection. `belongs_to :user`, `has_one_attached :image`

Post fields: `title`, `artist`, `body`, `genre`, `release_year`, `obi` (boolean), `cleaning_history` (text)

### Authorization Pattern

Authorization is done manually in `PostsController` — not via a policy library. After finding a post, the controller checks `@post.user != current_user` and redirects with an alert if unauthorized. `before_action :authenticate_user!` guards write actions; index/show are public.

### Discogs API Integration

`config/initializers/discogs.rb` defines `DISCOGS_CONFIG` (key, secret, token). The `PostsController#fetch_discogs` action (GET `/posts/fetch_discogs`) queries the Discogs API and returns JSON with `image_url`, `release_year`, and `genre`. This is called via Stimulus/JS from the new/edit form to auto-populate fields before saving.

Remote images returned from Discogs are downloaded and attached to the post via `open-uri` in `PostsController#create`.

### Locale

Default locale is Japanese (`:ja`). Flash messages and validation errors use `config/locales/` files. When adding user-facing strings, use I18n keys rather than hardcoded English text.

### Pagination & Search

`PostsController#index` scopes posts to `current_user.posts`, applies keyword search (title or artist) and genre filter, then paginates with Kaminari (10 per page).

### Routing

```
GET  /posts/fetch_discogs   # Discogs API proxy (collection action)
resources :posts            # Standard CRUD
devise_for :users
root → posts#index
```

## Key Conventions

- Views use Tailwind CSS utility classes; no separate CSS files.
- JS is bundled with `jsbundling-rails` + Stimulus controllers in `app/javascript/controllers/`.
- ActiveStorage handles image uploads; images are stored locally in development.
- Tests use Rails default Minitest with fixtures (`test/fixtures/`).
