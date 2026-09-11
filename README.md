# Ghost-Edition-Lanterns

The theme for [essays.lanterns.dev](https://essays.lanterns.dev), where the
[Lanterns](https://lanterns.dev) essays live. A fork of Ghost's
[Edition](https://github.com/TryGhost/Edition), restyled to match the lantern site.
Hosted on Ghost(Pro): the theme is built into a zip and uploaded; nothing is served
from this repo.

## Development

Styles are compiled with Gulp/PostCSS. You need [Node](https://nodejs.org/) and
[pnpm](https://pnpm.io/).

```bash
pnpm install
pnpm dev    # build, then watch assets/css/ and rebuild into assets/built/
pnpm zip    # build and package the theme into dist/lanterns.zip
pnpm test   # gscan, Ghost's theme validator
```

Upload the zip in Ghost Admin → Design → Change theme → Upload. `assets/built/` and
`dist/` are build output and are not tracked.

## Previewing

```bash
pnpm preview   # a local Ghost with the theme active, at localhost:2368
pnpm dev       # rebuild on every edit and push it into that Ghost
```

`pnpm preview` starts a throwaway Ghost 6 in Docker (needs a running Docker daemon, plus `python3`
and `rsync`) and activates the theme. What it fills the site with depends on one file:

- **With an Admin API key in `dev/.env`** it pulls the live site in: an allowlisted set of settings
  (identity, social accounts, navigation, metadata, comments, members, Portal) and every post and
  page, drafts included. Copy `dev/.env.example` to `dev/.env` and paste in an Admin API key from
  Ghost Admin → Settings → Integrations → Add custom integration. The file is gitignored and never
  leaves your machine; the live site is only read. Theme settings stay at their defaults, because
  Ghost does not let API keys read them.
- **Without one** it loads twelve posts of public-domain test content (`dev/posts.json`, Emerson).

Either way, if the site then has no publication cover, the lantern site's dock image
(`../lanterns.dev/assets/lanterns-background-layer.jpg`, the checkout beside this one) is set as one,
so the home-page hero renders. Only the local rig is written to.

`preview` prints the local admin login. `dev/rig.sh down` removes the container; `dev/rig.sh`
lists the individual steps.

## Licence

Code is MIT, © 2026 em lorien. Based on Edition, © Ghost Foundation, also MIT. The wordmark in
`assets/images/` is a brand asset, all rights reserved — see `assets/images/LICENSE.md`.
