#!/usr/bin/env bash
# A local Ghost to look at the theme in: Ghost 6 in Docker, sqlite, the theme mounted from a copy
# of this checkout, an owner account, the Admin settings the plan asks for, and twelve posts of
# public-domain test content. Nothing here is real; the password is a placeholder for a container
# that only ever listens on localhost.
#
#   dev/rig.sh up      build the theme, start the container, set the site up, activate the theme
#   dev/rig.sh posts   load the test posts (once, after up)
#   dev/rig.sh sync    copy the current checkout into the running container's theme
#   dev/rig.sh down    remove the container
#
# Ghost runs in development mode so template edits show after `sync` without a restart.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${TMPDIR:-/tmp}/lanterns-rig"
THEME="$WORK/theme"
URL=http://localhost:2368
API="$URL/ghost/api/admin"
JAR="$WORK/cookies.txt"
EMAIL=em@lanterns.dev
PASS=lanterns-local-rig

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
  (cd "$REPO" && pnpm exec gulp build >/dev/null)
  rsync -a --delete --exclude node_modules --exclude .git --exclude dist --exclude 'CLAUDE*' --exclude .github --exclude dev "$REPO/" "$THEME/"
  echo "theme synced -> $THEME"
  # Ghost lists a theme's templates at activation, so a new .hbs file needs a re-activate.
  if [ -f "$JAR" ] && docker ps --format '{{.Names}}' | grep -q '^ghost-lanterns$'; then
    login && api PUT "themes/lanterns/activate/" >/dev/null && echo "theme re-activated"
  fi
}

up() {
  sync
  docker rm -f ghost-lanterns >/dev/null 2>&1 || true
  docker run -d --name ghost-lanterns -p 127.0.0.1:2368:2368 -e url=$URL -e NODE_ENV=development \
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

posts() {
  login
  python3 "$REPO/dev/posts.py" "$WORK" | while IFS= read -r line; do
    api POST "posts/?source=html" "$line" | python3 -c 'import json,sys; d=json.load(sys.stdin); print("post:", d["posts"][0]["slug"] if "posts" in d else d)'
  done
}

case "${1:-}" in
  up) up ;; sync) sync ;; posts) posts ;; down) docker rm -f ghost-lanterns ;;
  *) echo "usage: dev/rig.sh up|posts|sync|down"; exit 1 ;;
esac
