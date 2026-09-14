# Handoff

*State of play for the essays theme. Updated 2026-09-14.*

## Where things are

Everything is on `main` and **live on essays.lanterns.dev** (the PR #9 zip, uploaded 2026-09-14):
the design brief (PR #5: two colours, the wordmark, our own subscribe form, comments, no search,
`noindex` on the author archive), the header (wordmark and two links, no drawer), the footer (one
line, sign-in in a dialog) and, since PR #9, the archive home: no hero, no intro page, the
subscribe form and then the list. Each is recorded in its section below.

## Next

1. **The eye gate** on the archive home: desktop and portrait mobile, against the live site.
2. **Ghost Admin on Ghost(Pro).** Hide the floating Portal button (Settings → Membership → Portal):
   no public essay opens Portal. The secondary navigation's Subscribe item can go, since the theme
   no longer renders that menu. The stock "Coming soon" placeholder post is on lanterns.dev's
   Essays list live: retitle or unpublish it before the first real essay (its excerpt also says
   "Em Lorien"). A **custom excerpt on every essay**: both lists show forty words, and the fallback
   is the first forty of the text. Look over Design & branding → theme settings, where every line
   of theme copy is a field pre-filled with the shipped wording. The publication cover no longer
   renders in the theme but stays set: `{{ghost_head}}` still uses it as the site's social preview
   image (`og:image`, `twitter:image`, JSON-LD) wherever no social image or feature image is set.
   Then the usual checks: every social account set in Admin renders as a
   footer icon; comments on; the Portal modal and the comments frame read acceptably (both are
   stock Ghost inside iframes). The site description only feeds `<meta>`.
3. Newsletter settings and the pseudonymity steps: the plan's lists.

## The archive (built 2026-09-14 on `archive`)

lanterns.dev is the one front door: its Essays page carries the intro copy (`content/en.js` there)
and lists the essays live, and this site is where they are read. Decided in lanterns.dev's
`docs/PLAN-pages.md`, "One site or two". So the home is what page one already was underneath: the
subscribe form (lanterns.dev's intro links here to subscribe), then the list, paginated. Gone: the
lantern hero (`partials/hero.hbs`, `hero.css`, the caret icon, the transparent header and the white
wordmark over it, the `continue_reading` setting, the rig's cover step; all in git history at
`e007938` if ever wanted), and the intro page (the `intro_page` setting, its `{{#get}}` on the
index, its `noindex`, the rig's `dev/pages.json`).

**The coupling to know about:** lanterns.dev's `essays.js` reads this site's Content API on
`lanterns.ghost.io` with the public content key (title, date, forty words, link). Rotating that key
in Admin (Settings → Integrations) or changing the ghost.io slug breaks the list there until
`essays.js` is updated. Custom excerpts feed both lists.

## Header navigation: the wordmark and two links

The header is the wordmark, linking to **lanterns.dev**, and Admin's primary menu beside it: two
links, Essays (`/`) and Lanterns Home (`https://lanterns.dev/`), in the bar on every width. No
mobile drawer, no burger, no Sign in or Subscribe buttons: the index carries the subscribe form,
and the footer carries the lanterns.dev link and the sign-in (next section). The wordmark link is
named for where it goes (`home_link_label`, a text setting) since its alt is the site title.

How it got here, the same day: the lantern-menu mirror (About / Research / Resources / Contact)
was confusing and too unlike the lantern site's own navigation, so the header went to the wordmark
alone; that turned out to be confusing the other way, so the two links came back, in the bar rather
than a drawer. The theme renders whatever Admin's primary menu holds; the plan's "nav mirrors the
lantern menu" line (`../plans/lanterns/essays-site.md`) is superseded and a to-do is filed there.

## The footer, and signing in without Portal

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
as a `<details>` disclosure and then a `:target` row; both shifted the layout,
hence the dialog. Both were exercised in the rig with an
impersonation link from the Admin API (`members/:id/signin_urls/`, on the rig's own host; on
another host the sign-out request is cross-origin and silently does nothing): on arrival Ghost
shows a small Portal "Success" toast top-right, dismissible, and that is the whole of Portal a
reader meets. Copy: six `text` settings (`signin_link`, `signin_label`, `signin_button`,
`signin_success`, `signin_close`, `signout_link`); the field placeholder and the in-flight text
are the subscribe form's. Seventeen settings of Ghost's twenty are used.

What still lives in Portal, untouched: account management (email, newsletter preferences) at
`#/portal/account`, which nothing links to; unsubscribe is in every email. The comments UI's own
sign-in prompt opens Portal, and so would the members-only gate (`partials/content-cta.hbs`,
rendered by `{{content}}` on a gated post; its buttons are `data-portal`), which no public essay
shows: if an essay is ever gated, swap those buttons for the theme's subscribe form and sign-in
dialog. Hide the floating Portal button in Admin (Settings → Membership → Portal).

Opening the dialog clears Ghost's state classes on the form, because Ghost never removes them: a
sent link (or a mistyped address, which Ghost answers the same way so as not to reveal who is a
member) would otherwise leave the second visit with no field. The backdrop darkens the page in
both schemes, ink at 60% over the light one and black at 80% over the dark one (a fog of paper
was tried for the dark scheme and was too bright); the panel is 8% ink on paper in both, so it
lifts off the darkened page. Both on the eye gate.

## Decisions taken in the design PR that the plan left open

- **No accent colour.** Links underline in ink. The lantern site's popups use an amber accent as a
  deliberate exception; not carried over.
- **Measure 38em** (~75 characters), the lantern site's as built. `site.md` still mentions ~45.
- **Dark follows `prefers-color-scheme`, no toggle.** The lantern site's popups have a tri-state
  toggle; a Ghost theme has no natural home for one.
- **Copy is Admin-editable**: `text` theme settings, defaults in `package.json`. They are
  single-line; the paragraphs of intro copy live on lanterns.dev.
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
