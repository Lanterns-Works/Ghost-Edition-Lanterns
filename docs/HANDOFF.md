# Handoff

*State of play for the essays theme. Updated 2026-09-12.*

## Where things are

The design brief in `../plans/lanterns/essays-site.md` is on `main` (PR #5, merged 2026-09-11):
two colours, the wordmark, our own subscribe form, comments, no search, `noindex` on the author
archive, a footer with the year and a GitHub link. **Not yet uploaded:** the live site still runs
the first upload of the fork (Lora and Mulish in its CSS).

The `hero` branch (PR #8) carries the lantern hero, the header (wordmark and two links, no drawer)
and the footer (one line, sign-in in a dialog): the three sections below. Rendered in the rig
against the live site's cover and its one placeholder post, desktop and 390px portrait, both
schemes; the review threads are all answered. Em's eye is the gate.

## Next

1. **Eye-gate the hero (em):** `pnpm preview` (with `dev/.env` it mirrors the live site, drafts
   included; see the README), then `pnpm dev` while editing. Desktop and portrait mobile, both
   colour schemes. Then merge, `pnpm zip`, and upload in Ghost Admin → Design → Change theme.
2. **Ghost Admin on Ghost(Pro), once the theme is up.** What the theme needs from Admin: a page with
   slug `intro` holding the index copy (paste the two paragraphs from
   `../plans/lanterns/essays-site.md`, "Index copy"; the "Get new essays by email" line is the
   form); the publication cover (Design & branding), which the rig found already set to the dock
   image, so the hero shows on upload; a **custom excerpt on every essay**, because the newest one
   is the hero's quote and the fallback is the first fifty words of the text; the primary navigation
   renamed to **Essays** and **Lanterns Home** (Settings → Navigation; the live labels are `essays`
   and `lanterns. home`, and the period is the visible difference); the floating Portal button
   hidden (Settings → Membership → Portal), since no public essay opens Portal, and the secondary
   navigation's Subscribe item can go, since the theme no longer renders that menu; and a look at
   Design & branding → theme settings, where every line of theme copy is a field pre-filled with the
   shipped wording. Then the usual checks: every social account set in Admin renders as a footer
   icon; comments on; the Portal modal and the comments frame read acceptably (both are stock Ghost
   inside iframes). The site description only feeds `<meta>`. Check the hero's `<img>` on the live
   site: Ghost(Pro) keeps the cover on `storage.ghost.io`, and `img_url` only resizes images on the
   site's own URL, so the srcset may collapse to the original (114 KB as uploaded, acceptable). That
   host does serve `size/w1920/` and `format/webp/` paths, so a hand-built srcset is possible if it
   matters.
3. Newsletter settings and the pseudonymity steps: the plan's lists.

## The lantern hero (Maria's spec 2026-09-11, built the same day on `hero`)

The dock image back on the home page, so the two sites feel continuous. Home page, first page
only, and only once Admin has a publication cover: `partials/hero.hbs`, included from `index.hbs`,
styled in `assets/css/site/hero.css`. Edition's own cover (in git history at `ec6e9f9`) was the
reference, not the base: none of its JS survives.

- **Full viewport** (`min-height: 100svh`) of `@site.cover_image` through `{{img_url … size=}}`
  with a srcset over the theme's `image_sizes`, `object-position: 85% 60%` so the lantern (right
  third of the photo) stays in frame in portrait. A 0.3 ink scrim over the image, a 0.4 halo
  under the quote and the control, and a text shadow carry the paper text; the scrim and the halo
  are the two knobs. Review measured portrait contrast: with those, the flame core under a few
  characters stays below 4.5:1 and the rest passes; the same words are in the list below.
- **Layout is grid rows** (`1fr auto 1fr auto`): the quote centred in the room above the control,
  so a long excerpt, a landscape phone or 200% zoom grow the section rather than overlap.
- **Header transparent over it:** the shared CSS's own `is-head-transparent` variant, added to
  the body class in `default.hbs` on the same condition. The variant paints the links in
  `--color-white`, which `basics.css` resolves on `:root` to the scheme's paper (ink in dark mode),
  so the header fixes it to paper (the trap: a custom property resolves where it is declared, so
  re-pinning `--paper` alone reached nothing). The wordmark gets a `<source>` with no media query
  ahead of the dark-scheme one, so it is white in both schemes; the focus ring is set to paper too.
- **The quote:** the newest post, `{{excerpt words="50"}}`, which outputs a custom excerpt
  verbatim and otherwise the first fifty words. Italic, in curly quotes typed in the template,
  the whole block a link to the essay, with the essay's title as a `<cite>` line under it: the
  spec did not ask for a title, but a link needs a visible affordance and the title is the
  smallest one. Drop the `<cite>` if em prefers the bare quote.
- **"Continue reading" over a caret** is a plain anchor to `#essays`, the `<main>`, with
  `scroll-behavior: smooth` on `html` (off under `prefers-reduced-motion`). No JS. The wording is
  the `continue_reading` theme setting. The caret is Edition's `icons/caret-down` partial,
  restored from history.
- **Below it, the index as before.** `.site-content` gives up its top padding on the hero page and
  `.site-main` takes it, so the hero sits flush under the header and the index sits where it did.
- **The rig** sets the lantern site's dock image (`../lanterns.dev/assets/…`) as the local cover
  when the site has none (`dev/rig.sh cover`, run by `preview`), so the hero renders against test
  posts too.
- **Checked in the rig** (2026-09-11): desktop at 2079px and a 390×800 portrait frame, light and
  dark, the anchor landing on the index; then an adversarial
  review (six lenses, two skeptics per finding) whose survivors are all in: the scrim had painted
  under the image, the header's focus ring was invisible over the sky, the control could overlap
  the quote on short viewports. One thing to judge by eye: in portrait the quote sits over the
  lantern; the halo is what keeps it legible there.

## Header navigation: the wordmark and two links (Maria, 2026-09-12)

The header is the wordmark, linking to **lanterns.dev**, and Admin's primary menu beside it: two
links, Essays (`/`) and Lanterns Home (`https://lanterns.dev/`), in the bar on every width. No
mobile drawer, no burger, no Sign in or Subscribe buttons: the index carries the subscribe form and
the intro page, and the footer carries the lanterns.dev link and the sign-in (next section). Any
further links to the lantern site's sections belong in the intro page copy. The wordmark link is
named for where it goes (`home_link_label`, a text setting) since its alt is the site title.

How it got here, the same day: the lantern-menu mirror (About / Research / Resources / Contact)
was confusing and too unlike the lantern site's own navigation, so the header went to the wordmark
alone; that turned out to be confusing the other way, so the two links came back, in the bar rather
than a drawer. The theme renders whatever Admin's primary menu holds; the plan's "nav mirrors the
lantern menu" line (`../plans/lanterns/essays-site.md`) is superseded and a to-do is filed there.

## The footer, and signing in without Portal (Maria, 2026-09-12)

One line in the bottom-right corner, as on the lantern site: `lanterns.dev · © YYYY · Sign in`,
then the LinkedIn icon (Admin's social accounts) and the GitHub icon, small and muted. Admin's
secondary menu is not rendered any more: its Subscribe item opened the Portal popup, which is stock
Ghost and jars against the site, and the index and every essay already carry the subscribe form.

Sign in is the theme's own (`partials/member-link.hbs`): the link opens a one-field form in a
native `<dialog>` (`showModal()`, a few lines in `main.js`), so nothing on the page moves; the
browser puts it in the top layer, makes the page behind inert, focuses the field, and closes it on
Escape; the close control and a click on the backdrop close it too. The form is
`data-members-form="signin"`, which sends Ghost's sign-in link by email, the documented way to sign
in without Portal. It reuses the subscribe form's classes, so Ghost's loading, success and error
states and the focus move in `main.js` apply. Signed in, the link is Sign out
(`data-members-signout`, also documented). Two earlier versions revealed the form in the page,
as a `<details>` disclosure and then a `:target` row; both shifted the layout (Maria, 2026-09-12),
hence the dialog. Both were exercised in the rig with an
impersonation link from the Admin API (`members/:id/signin_urls/`, on the rig's own host; on
another host the sign-out request is cross-origin and silently does nothing): on arrival Ghost
shows a small Portal "Success" toast top-right, dismissible, and that is the whole of Portal a
reader meets. Copy: six `text` settings (`signin_link`, `signin_label`, `signin_button`,
`signin_success`, `signin_close`, `signout_link`); the field placeholder and the in-flight text
are the subscribe form's. Nineteen settings of Ghost's twenty are now used.

What still lives in Portal, untouched: account management (email, newsletter preferences) at
`#/portal/account`, which nothing links to; unsubscribe is in every email. The comments UI's own
sign-in prompt opens Portal, and so would the members-only gate (`partials/content-cta.hbs`,
rendered by `{{content}}` on a gated post; its buttons are `data-portal`), which no public essay
shows: if an essay is ever gated, swap those buttons for the theme's subscribe form and sign-in
dialog. Hide the floating Portal button in Admin (Settings → Membership → Portal).

Opening the dialog clears Ghost's state classes on the form, because Ghost never removes them: a
sent link (or a mistyped address, which Ghost answers the same way so as not to reveal who is a
member) would otherwise leave the second visit with no field. In the dark scheme the backdrop is
paper at 40%, which fogs the page rather than dims it, since a dark scrim over ink-dark paper does
nothing; the panel is 8% ink on paper in both schemes so it lifts off the page. Both on the eye
gate.

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
- **Theme JS is two snippets** (`assets/js/main.js`): a member form hides its row on success, which
  drops focus, so focus is moved to the outcome message; and the sign-in dialog's open and close.
- **Error pages:** `error-404.hbs` carries the plan's line; `error.hbs` covers the rest.

## Known gaps

- Portal and the comments UI are stock Ghost. Comments pick light or dark from the page text colour
  at load.
- Search is out of the theme; whether Ghost's Cmd/Ctrl+K still opens its modal is unconfirmed.
- The subscribe form's error text is whatever Ghost returns.
