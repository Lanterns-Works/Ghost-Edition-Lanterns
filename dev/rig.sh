#!/usr/bin/env bash
# A local Ghost to look at the theme in: Ghost 6 in Docker, sqlite, the theme mounted from a copy
# of this checkout, an owner account, the Admin settings the plan asks for, and twelve posts of
# public-domain test content (dev/posts.json). Nothing here is real; the password is a placeholder
# for a container that only ever listens on localhost.
#
#   pnpm preview       = dev/rig.sh preview: up, then pull if dev/.env holds a key, else posts
#   dev/rig.sh up      build the theme, start the container, set the site up, activate the theme
#   dev/rig.sh posts   load the test posts and the intro page (once, after up)
#   dev/rig.sh pull    replace the rig's settings and content with the live site's (needs
#                      LANTERNS_GHOST_URL and LANTERNS_GHOST_ADMIN_KEY in dev/.env; see dev/.env.example)
#   dev/rig.sh cover   set the lantern site's dock image as the publication cover if there is none,
#                      so the home-page hero renders (preview does this after pull or posts)
#   dev/rig.sh sync    copy the current checkout into the running container's theme (pnpm dev
#                      does this after every build while the rig is up)
#   dev/rig.sh down    remove the container
#
# Ghost runs in development mode so template edits show after `sync` without a restart, and
# without staff device verification, which would email a code the rig cannot send.
# RIG_PORT (default 2368) picks the local port.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${RIG_PORT:-2368}"
URL="http://localhost:$PORT"
WORK="${TMPDIR:-/tmp}/lanterns-rig-$PORT"
THEME="$WORK/theme"
API="$URL/ghost/api/admin"
JAR="$WORK/cookies.txt"
EMAIL=em@lanterns.dev
PASS=lanterns-local-rig
COVER="$REPO/../lanterns.dev/assets/lanterns-background-layer.jpg"  # the lantern site's checkout, beside this one

api() { # api METHOD path [json]
  if [ -n "${3:-}" ]; then
    curl -sS -X "$1" "$API/$2" -b "$JAR" -c "$JAR" -H "Origin: $URL" -H "Content-Type: application/json" -d "$3"
  else
    curl -sS -X "$1" "$API/$2" -b "$JAR" -c "$JAR" -H "Origin: $URL"
  fi
}
login() { api POST "session/" "{\"username\":\"$EMAIL\",\"password\":\"$PASS\"}" >/dev/null; }

sync() {
  mkdir -p "$THEME"
  [ -n "${RIG_SKIP_BUILD:-}" ] || (cd "$REPO" && pnpm exec gulp build >/dev/null)
  rsync -a --delete --exclude node_modules --exclude .git --exclude dist --exclude 'CLAUDE*' --exclude .github --exclude dev "$REPO/" "$THEME/"
  echo "theme synced -> $THEME"
  # Ghost lists a theme's templates at activation, so a new .hbs file needs a re-activate.
  if [ -f "$JAR" ] && docker ps --format '{{.Names}}' | grep -q "^ghost-lanterns-$PORT\$"; then
    login && api PUT "themes/lanterns/activate/" >/dev/null && echo "theme re-activated"
  fi
}

up() {
  sync
  docker rm -f "ghost-lanterns-$PORT" >/dev/null 2>&1 || true
  docker run -d --name "ghost-lanterns-$PORT" -p "127.0.0.1:$PORT:2368" -e url=$URL -e NODE_ENV=development \
    -e security__staffDeviceVerification=false \
    -v "$THEME:/var/lib/ghost/content/themes/lanterns" ghost:6 >/dev/null
  for _ in $(seq 1 60); do curl -sf "$URL/ghost/api/admin/site/" >/dev/null 2>&1 && break; sleep 2; done
  rm -f "$JAR"
  api POST "authentication/setup/" "{\"setup\":[{\"name\":\"em lorien\",\"email\":\"$EMAIL\",\"password\":\"$PASS\",\"blogTitle\":\"lanterns.\"}]}" >/dev/null
  login
  api PUT "themes/lanterns/activate/" | python3 -c 'import json,sys; t=json.load(sys.stdin)["themes"][0]; print("theme:", t["name"], "active" if t["active"] else "NOT active", "| warnings:", len(t.get("warnings",[])))'
  api PUT "settings/" '{"settings":[
    {"key":"title","value":"lanterns."},
    {"key":"description","value":"Written from inside the work, by someone who builds with these tools every day, enjoys it more than is comfortable, and does not know where it ends up."},
    {"key":"accent_color","value":"#160e0e"},
    {"key":"comments_enabled","value":"all"},
    {"key":"navigation","value":"[{\"label\":\"About\",\"url\":\"https://lanterns.dev/#about\"},{\"label\":\"Research\",\"url\":\"https://lanterns.dev/#research\"},{\"label\":\"Resources\",\"url\":\"https://lanterns.dev/#resources\"},{\"label\":\"Contact\",\"url\":\"https://lanterns.dev/#contact\"}]"},
    {"key":"secondary_navigation","value":"[]"},
    {"key":"facebook","value":""},
    {"key":"twitter","value":""}
  ]}' | python3 -c 'import json,sys; d=json.load(sys.stdin); print("settings:", "ok" if "settings" in d else d)'
  echo "up: $URL   admin: $URL/ghost/  ($EMAIL / $PASS)"
}

posts() { # dev/posts.json: twelve posts of public-domain Emerson, one long enough for the reading column; dev/pages.json: the intro page
  login
  for kind in posts pages; do
    python3 -c 'import json,sys; [print(json.dumps({sys.argv[2]:[p]})) for p in json.load(open(sys.argv[1]))]' "$REPO/dev/$kind.json" "$kind" | while IFS= read -r line; do
      api POST "$kind/?source=html" "$line" | python3 -c 'import json,sys; d=json.load(sys.stdin); k=[k for k in d if k!="meta"][0]; print(k[:-1]+":", d[k][0]["slug"] if k in ("posts","pages") else d)'
    done
  done
}

cover() { # the hero wants Admin's publication cover; until the live site has one, stand in with the dock image
  login
  if api GET "settings/" | python3 -c 'import json,sys; s={x["key"]:x["value"] for x in json.load(sys.stdin)["settings"]}; sys.exit(0 if s.get("cover_image") else 1)'; then
    echo "cover: already set"; return
  fi
  [ -f "$COVER" ] || { echo "cover: not set, $COVER is missing (the hero needs one; see README)"; return; }
  url=$(curl -sS -X POST "$API/images/upload/" -b "$JAR" -c "$JAR" -H "Origin: $URL" -F "file=@$COVER" -F purpose=image -F ref=cover \
    | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["images"][0]["url"]) if "images" in d else sys.exit("cover upload: "+json.dumps(d))')
  api PUT "settings/" "{\"settings\":[{\"key\":\"cover_image\",\"value\":\"$url\"}]}" | python3 -c 'import json,sys; d=json.load(sys.stdin); print("cover:", sys.argv[1] if "settings" in d else d)' "$url"
}

loadenv() { if [ -f "$REPO/dev/.env" ]; then set -a; . "$REPO/dev/.env"; set +a; fi; }  # plain KEY=value lines, exported
# The same precondition dev/pull.py checks: a live URL and a key of the shape Ghost issues (id:secret).
has_live() { [ -n "${LANTERNS_GHOST_URL:-}" ] && case "${LANTERNS_GHOST_ADMIN_KEY:-}" in *:*) true ;; *) false ;; esac; }

pull() {
  loadenv
  python3 "$REPO/dev/pull.py" "$URL" "$EMAIL" "$PASS"
}

preview() {
  up
  loadenv
  if has_live; then pull; else
    echo "dev/.env is missing the live URL or an Admin API key, so loading the test posts instead (see dev/.env.example)"; posts
  fi
  cover
  echo; echo "preview: $URL   (pnpm dev keeps it in step with your edits; dev/rig.sh down removes it)"
}

case "${1:-}" in
  up) up ;; preview) preview ;; sync) sync ;; posts) posts ;; pull) pull ;; cover) cover ;; down) docker rm -f "ghost-lanterns-$PORT" ;;
  *) echo "usage: dev/rig.sh up|preview|posts|pull|cover|sync|down"; exit 1 ;;
esac
