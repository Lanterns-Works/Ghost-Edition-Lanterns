# Handoff

*State of play for the essays theme. Updated 2026-09-10.*

## Where things are

The design brief in `../plans/lanterns/essays-site.md` is built on the `design` branch (PR #4):
two colours, the wordmark, our own subscribe form, comments, no search, `noindex` on the author
archive, a footer with the year and a GitHub link. Rendered locally on desktop and at 390px
portrait against a 2,500-word public-domain essay — **not yet against a real essay**, which is
the gate.

## Next

1. **Eye-gate (em):** `dev/rig.sh up && dev/rig.sh posts`, paste a real essay in at
   `localhost:2368/ghost/`, look on desktop and portrait mobile in both colour schemes. Then
   merge, `pnpm zip`, and upload in Ghost Admin → Design → Change theme.
2. **Ghost Admin on Ghost(Pro), once the theme is up:** title `lanterns.`; description (Ghost caps
   it at 200 characters; it only feeds `<meta>` now, the index copy lives in `index.hbs`); accent
   `#160e0e`; navigation About / Research / Resources / Contact → `https://lanterns.dev/#about`
   etc.; **clear the Facebook and X handles Ghost seeds** (they render as footer icons); comments
   on; open the Portal modal and the comments frame and check they read acceptably — both are
   stock Ghost inside iframes.
3. Newsletter settings and the pseudonymity steps: the plan's lists.

## Decisions taken in the design PR that the plan left open

- **No accent colour.** Links underline in ink. The lantern site's popups use an amber accent as a
  deliberate exception; not carried over.
- **Measure 38em** (~75 characters), the lantern site's as built. `site.md` still mentions ~45.
- **Dark follows `prefers-color-scheme`, no toggle.** The lantern site's popups have a tri-state
  toggle; a Ghost theme has no natural home for one.
- **Real pagination links** (older / newer), not Edition's JS load-more.
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
