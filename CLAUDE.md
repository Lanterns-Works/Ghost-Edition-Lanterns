# Ghost-Edition-Lanterns

The theme for **essays.lanterns.dev** — a fork of Ghost's Edition, restyled to match the lantern
site. Hosted on Ghost(Pro); we build a zip and upload it, nothing of ours is served elsewhere.

- **Read first:** `docs/HANDOFF.md` (state of play, what's next), then `../plans/lanterns/essays-site.md`
  (the plan: decisions, Ghost facts, design brief, open items) and `../plans/lanterns/soul.md` (what
  Lanterns is, the style rule). The lantern site itself is `../lanterns.dev` — its `CLAUDE.md`
  carries the shared conventions.
- **Build:** `pnpm install`, `pnpm dev` (watch), `pnpm zip` → `dist/lanterns.zip` for upload in
  Ghost Admin → Design → Change theme. `pnpm test` (build, then gscan) is the validation gate.
  The Gulp/PostCSS build is kept on purpose — it came with Edition and saves building from scratch.
- **Look at it:** `pnpm preview` → a local Ghost 6 in Docker at `localhost:2368` with the theme
  active, filled from the live site when `dev/.env` holds an Admin API key (see `dev/.env.example`
  and the README), else with test posts. `pnpm dev` pushes every edit into it.
- **Style:** Lanterns is capitalized in prose (Maria, 2026-09-12); lowercase only where it is the
  wordmark: the logo image and its alt, the site title `lanterns.`, and the copyright line. em lorien
  stays lowercase. **Georgia**
  everywhere (the lantern site's stack in `basics.css`; nothing vendored). **Two colours**,
  `#160e0e` / `#e7e5de`, swapped by `prefers-color-scheme`; everything else is an alpha of ink,
  no accent. **No bold anywhere**: `font-weight: 500` site-wide (Maria, 2026-09-10), which Georgia
  renders as regular. Accent colour in Ghost Admin is `#160e0e` (Portal reads it).
- **Copy lives in Ghost Admin, not in templates.** The index intro is the page whose slug is the
  `intro_page` theme setting; every other line of theme copy is a `text` setting under Design &
  branding, with the shipped wording as its default in `package.json`. Add a setting rather than
  hardcoding a string.
- **Writing is attributed to em lorien.** Staff user name on Ghost is em lorien.
- **Identity:** commit as `em lorien <em@lanterns.dev>` (git conditional include for the Lanterns
  folder). Switch `gh` to `em-lorien` before repo or PR work. No `Co-Authored-By` trailers.
  PR review is the Claude GitHub app (workflows in `.github/`) — handle its findings before merging.
- **The gate is em's eye** — desktop and portrait mobile, against a real essay.
