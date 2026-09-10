# Ghost-edition-Lanterns

The theme for **essays.lanterns.dev** — a fork of Ghost's Edition, restyled to match the lantern
site. Hosted on Ghost(Pro); we build a zip and upload it, nothing of ours is served elsewhere.

- **Read first:** `../plans/lanterns/essays-site.md` (the plan: decisions, Ghost facts, design
  brief, open items) and `../plans/lanterns/soul.md` (what lanterns is, the style rule).
  The lantern site itself is `../lanterns.dev` — its `CLAUDE.md` carries the shared conventions.
- **Build:** `pnpm install`, `pnpm dev` (watch), `pnpm zip` → `dist/lanterns.zip` for upload in
  Ghost Admin → Design → Change theme. `pnpm test` (build, then gscan) is the validation gate.
  The Gulp/PostCSS build is kept on purpose — it came with Edition and saves building from scratch.
- **Style:** `lanterns` lowercase in prose; the wordmark image carries the period. Design target,
  not yet applied (see the to-do list): **Georgia** replaces Edition's Lora and Mulish (same face
  as the lantern site and the newsletter), two colours, `#160e0e` / `#e7e5de`. Accent colour in
  Ghost Admin is `#160e0e`.
- **Writing is attributed to em lorien.** Staff user name on Ghost is em lorien.
- **Identity:** commit as `em lorien <em@lanterns.dev>` (git conditional include for the Lanterns
  folder). Switch `gh` to `em-lorien` before repo or PR work. No `Co-Authored-By` trailers.
  PR review is the Claude GitHub app — copy the workflows from `../lanterns.dev/.github/`.
- **The gate is em's eye** — desktop and portrait mobile, against a real essay.
