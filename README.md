# Ghost-Edition-Lanterns

The theme for [essays.lanterns.dev](https://essays.lanterns.dev), where the
[lanterns](https://lanterns.dev) essays live. A fork of Ghost's
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

## Looking at it

`dev/rig.sh up` starts a throwaway Ghost 6 in Docker (needs a running Docker daemon, plus
`python3` and `rsync`) with the theme active at `localhost:2368`; `dev/rig.sh posts` loads twelve
posts of public-domain test content (Emerson, fetched from Project Gutenberg once and cached under
`$TMPDIR`); `dev/rig.sh sync` copies edits in; `dev/rig.sh down` removes it. The admin login is
printed by `up`.

## Licence

Code is MIT, © 2026 em lorien. Based on Edition, © Ghost Foundation, also MIT. The wordmark in
`assets/images/` is a brand asset, all rights reserved — see `assets/images/LICENSE.md`.
