# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Zagreb Mukerjee's personal academic site (https://zagrebmukerjee.com), built from the **Academic Pages** Jekyll template (a detached fork of Minimal Mistakes). Almost all real content lives in `_config.yml` (site + sidebar author info) and `_pages/about.md`; most other pages/collections are still template sample content.

The site is currently consolidated into a **single CV-style page**: `_pages/about.md` has `permalink: /` with sections Research (Working Papers / Work in Progress) → Dissertation Committee → Teaching → CV. The top nav in `_data/navigation.yml` is intentionally empty (entries commented out). To add a section back as its own page, re-enable its entry in `navigation.yml`.

- `about.md` deliberately has **no `title:` front matter**: `page.title` drives both the browser `<title>` and an `<h1>`, and since it would equal the site title the tab read "Zagreb Mukerjee - Zagreb Mukerjee". Don't add one back.
- The template's sample content (`_posts/`, `_publications/`, `_talks/`, `_portfolio/`, `_pages/publications.html`, etc.) is intentionally kept but unlinked, in case the site is split into multiple pages later. The "destination conflict" warnings at build time come from these sample files and are harmless. Don't delete them unless asked.

## Commands

```bash
bundle install                                   # Ruby deps (Gemfile.lock is gitignored)
bundle exec jekyll serve -l -H localhost         # dev server at localhost:4000, live reload
bundle exec jekyll build --strict_front_matter   # what CI runs (JEKYLL_ENV=production)
npm run build:js                                 # re-minify assets/js/main.min.js after editing assets/js/*.js
docker compose up                                # alternative: containerized serve on :4000
```

Changes to `_config.yml` require restarting `jekyll serve`. There are no tests; a clean `jekyll build --strict_front_matter` is the check.

## Local environment notes

- The Gemfile was switched from the `github-pages` gem to plain `jekyll ~> 4.3` (plus `csv`, `bigdecimal`, and Windows `tzinfo-data`) so it builds locally on Windows with a modern Ruby (4.x).
- `_plugins/ruby_compat.rb` re-adds `Object#tainted?/taint/untaint` as no-ops, because Ruby 3.2+ removed them but the Liquid version Jekyll uses still calls them. Don't delete it unless Liquid is upgraded.
- GitHub Pages' default (classic) build runs in safe mode with its own pinned Jekyll and ignores `_plugins/` and the Gemfile — so only use whitelisted plugins (`plugins:`/`whitelist:` in `_config.yml`) for anything that must work in production.

## Architecture

- **Content collections** (defined under `collections:` in `_config.yml`, each output at `/:collection/:path/`): `_publications`, `_talks`, `_teaching`, `_portfolio`, plus `_posts`. Listing pages for them live in `_pages/` (e.g. `publications.html`, `talks.html`). Per-collection front-matter defaults (layout, `author_profile`, etc.) are set in the `defaults:` block of `_config.yml`, so individual files usually only need title/date/venue fields.
- **Layouts**: `_layouts/single.html` is the workhorse for pages and collection items; `default.html` wraps everything; `talk.html` and `cv-layout.html` are specialized.
- **Sidebar**: `_includes/author-profile.html` renders the `author:` block of `_config.yml`. Each social/academic field only shows an icon if set. The avatar block is wrapped in `{% if author.avatar %}` (local change), so leaving `avatar` blank hides the photo.
- **Theming**: `site_theme` in `_config.yml` selects a color scheme; styles are in `_sass/`.
- **CV**: two variants — `_pages/cv.md` (Markdown) and `_pages/cv-json.md` (renders `_data/cv.json`). `scripts/update_cv_json.sh` regenerates `cv.json` from `cv.md` via `scripts/cv_markdown_to_json.py`.
- **Content generators**: `markdown_generator/` has Python scripts/notebooks that turn `publications.tsv`/`talks.tsv` (or BibTeX via `pubsFromBib.py`) into collection Markdown files. `talkmap.py`/`talkmap.ipynb` geocode talk locations into `talkmap/` (also run by the `scrape_talks.yml` workflow on pushes touching `_talks/`).
- **Static files**: anything in `files/` is served at `/files/<name>` (e.g. paper PDFs).

## CI

The working branch is `main` (renamed from `master`); GitHub Pages should build from `main` (root). `.github/workflows/` is inherited from upstream: `jekyll-build.yml` builds with Ruby 3.2, triggered via `workflow_run` after the `bad-pr.yml` workflow on `main`. `bad-pr.yml` / `close-tests.yml` are upstream PR-hygiene workflows.
