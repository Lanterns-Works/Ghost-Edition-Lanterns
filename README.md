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

## Licence

Code is MIT, © 2026 em lorien. Based on Edition, © Ghost Foundation, also MIT.
