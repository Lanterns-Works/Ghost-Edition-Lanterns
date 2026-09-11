# Handoff

*State of play for the essays theme. Updated 2026-09-10.*

## Where things are

The design brief in `../plans/lanterns/essays-site.md` is built on the `design` branch (PR #5):
two colours, the wordmark, our own subscribe form, comments, no search, `noindex` on the author
archive, a footer with the year and a GitHub link. Rendered locally on desktop and at 390px
portrait against a 2,500-word public-domain essay — **not yet against a real essay**, which is
the gate.

## Next

1. **Eye-gate (em):** `pnpm preview` (with `dev/.env` it mirrors the live site, drafts included;
   see the README), then `pnpm dev` while editing. Look on desktop and portrait mobile in both
   colour schemes. Then merge, `pnpm zip`, and upload in Ghost Admin → Design → Change theme.
2. **Ghost Admin on Ghost(Pro), once the theme is up.** Two things the theme needs from Admin:
   a page with slug `intro` holding the index copy (paste the two paragraphs from
   `../plans/lanterns/essays-site.md`, "Index copy"; the "Get new essays by email" line is the
   form), and a look at Design & branding → theme settings, where every line of theme copy is a
   field pre-filled with the shipped wording. Then the usual checks: every social account set in
   Admin renders as a footer icon; comments on; the Portal modal and the comments frame read
   acceptably (both are stock Ghost inside iframes). The site description only feeds `<meta>`.
3. Newsletter settings and the pseudonymity steps: the plan's lists.

## Next design pass: the lantern hero (Maria, 2026-09-11)

Keep everything built so far and put the lantern-on-the-dock image back on the home page, so the
two sites feel continuous. Reference: Edition's own full-screen cover, which the design PR removed;
its mechanics are in git history (`git show ec6e9f9:partials/cover.hbs`,
`ec6e9f9:assets/css/site/cover.css`, the `with-full-cover` / `is-head-transparent` body classes and
the `cover()` scroll in `ec6e9f9:assets/js/main.js`).

- **Home page only, first page only.** A full-viewport hero (`100svh`, not Edition's JS toolbar
  hack) of the dock image. Paged index, posts, pages: unchanged.
- **The image.** The lantern site's `assets/lanterns-background-layer.jpg` (3840×2143, a brand
  asset, all rights reserved). Prefer Ghost Admin's publication cover (`@site.cover_image`,
  Design & branding) over shipping it in the theme: Admin manages it and `{{img_url ... size=}}`
  serves responsive sizes. Crop so the lantern stays in frame in portrait (`object-position` to
  the right).
- **Header transparent over it**, the current header otherwise: white wordmark, paper-coloured
  nav and buttons, whatever the colour scheme, since the image is dark. Below the hero the
  two-colour scheme as now.
- **Centre: the newest essay's excerpt** as a block quote in quotation marks (`custom_excerpt`,
  else `excerpt`), linking to the essay. Paper text; a light scrim or text shadow for contrast.
- **Bottom: "Continue reading" above a down caret**, one control that scrolls to the content.
  The text is the button's label. Make the wording a theme setting like the rest of the copy.
- **Then the current index**: intro page, subscribe form, essay list.
- Gate as before: desktop and portrait mobile, both schemes, against the real image and a real
  excerpt (`pnpm preview` pulls both once the cover is set in Admin).

## Decisions taken in the design PR that the plan left open

- **No accent colour.** Links underline in ink. The lantern site's popups use an amber accent as a
  deliberate exception; not carried over.
- **Measure 38em** (~75 characters), the lantern site's as built. `site.md` still mentions ~45.
- **Dark follows `prefers-color-scheme`, no toggle.** The lantern site's popups have a tri-state
  toggle; a Ghost theme has no natural home for one.
- **Copy is Admin-editable**: ten `text` theme settings (defaults in `package.json`) plus the intro
  as a Ghost page, because Ghost's site description is capped at 200 characters and text settings
  are single-line, so paragraphs need the editor. The intro page is also served at `/intro/`.
- **Real pagination links** (older / newer), not Edition's JS load-more. The partial is included
  with a literal `{{> "pages-nav"}}` rather than Ghost's `{{pagination}}` helper: gscan only credits
  a partial's `{{@custom}}` usage when a template names it that way, so with the helper the two
  link-text settings counted as unused.
- **Gone:** reading time, tag links, share buttons, related posts, featured posts, the cover, author
  boxes, and every Edition custom setting. Tag archives still render at `/tag/…` if tags are ever
  used; the plan's tag question stays open.
- **`card_assets` stays `true`;** callout, bookmark and button cards are restyled to the two colours.
  Other cards show Ghost's colours until an essay uses one.
- **No `color-scheme` declaration:** it made the browser paint a white canvas behind the comments
  iframe in dark mode.
- **`font-weight: 500 !important` site-wide** (zero bold). It also flattens `<strong>`, `<b>` and table
  headers in essay text; add a `.gh-content strong` exception if that turns out unwanted.
- **Theme JS is a few lines** (`assets/js/main.js`): the burger's open state for assistive tech, the
  page behind the open menu made inert, Escape to close, and focus moved to the subscribe form's
  outcome message.
- **Error pages:** `error-404.hbs` carries the plan's line; `error.hbs` covers the rest.

## Known gaps

- Portal and the comments UI are stock Ghost. Comments pick light or dark from the page text colour
  at load.
- Search is out of the theme; whether Ghost's Cmd/Ctrl+K still opens its modal is unconfirmed.
- The subscribe form's error text is whatever Ghost returns.
