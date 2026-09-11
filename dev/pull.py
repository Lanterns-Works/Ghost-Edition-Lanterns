# Copy the live site's Admin settings, theme settings, posts and pages into the local rig, so the
# theme is previewed against real content and real settings without setting anything up twice.
# One direction only: live -> local. Needs an Admin API key from the live site (Ghost Admin ->
# Settings -> Integrations -> Add custom integration), given as LANTERNS_GHOST_ADMIN_KEY=id:secret,
# and the live URL as LANTERNS_GHOST_URL. Usage (from dev/rig.sh pull): pull.py LOCAL_URL EMAIL PASS
import base64, hashlib, hmac, json, os, sys, time, urllib.request, urllib.error, http.cookiejar

live = os.environ.get("LANTERNS_GHOST_URL", "").rstrip("/")
key = os.environ.get("LANTERNS_GHOST_ADMIN_KEY", "")
if not live or ":" not in key:
    sys.exit("set LANTERNS_GHOST_URL and LANTERNS_GHOST_ADMIN_KEY=id:secret (see dev/rig.sh)")
local, email, password = sys.argv[1].rstrip("/"), sys.argv[2], sys.argv[3]

def b64(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode()
def token():  # Ghost Admin API JWT: HS256, kid = key id, secret is hex, five-minute life
    kid, secret = key.split(":")[0], key.split(":")[-1]  # Admin shows the key as id:secret
    now = int(time.time())
    head = b64(json.dumps({"alg": "HS256", "typ": "JWT", "kid": kid}).encode())
    body = b64(json.dumps({"iat": now, "exp": now + 300, "aud": "/admin/"}).encode())
    sig = b64(hmac.new(bytes.fromhex(secret), f"{head}.{body}".encode(), hashlib.sha256).digest())
    return f"{head}.{body}.{sig}"

jar = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))
def call(base, method, path, data=None, auth=None):
    req = urllib.request.Request(f"{base}/ghost/api/admin/{path}", method=method,
        data=json.dumps(data).encode() if data is not None else None,
        headers={"Content-Type": "application/json", "Origin": base, "Accept-Version": "v6.0", **({"Authorization": "Ghost " + auth} if auth else {})})
    try:
        with opener.open(req) as r:
            raw = r.read()
            return json.loads(raw) if raw.strip().startswith(b"{") else {}  # session login answers 201 with text
    except urllib.error.HTTPError as e:
        if e.code == 403 and "custom_theme_settings" in path:
            return None  # Ghost does not let API keys read theme settings; the defaults stay
        raise SystemExit(f"{method} {path}: {e.code} {e.read().decode()[:300]}")
    except urllib.error.URLError as e:
        raise SystemExit(f"{method} {base}/{path}: {e.reason} — is the rig up? (dev/rig.sh up)")

def browse(base, kind, qs, auth=None):  # Ghost caps every page at 100 rows, limit=all included
    out, page = [], 1
    while True:
        d = call(base, "GET", f"{kind}/?{qs}&limit=100&page={page}", auth=auth)
        out += d[kind]
        page = d.get("meta", {}).get("pagination", {}).get("next")
        if not page: return out

# --- read the live site
t = token()
settings = call(live, "GET", "settings/", auth=t)["settings"]
theme = call(live, "GET", "custom_theme_settings/", auth=t)
theme = theme["custom_theme_settings"] if theme else None
posts = browse(live, "posts", "formats=html&include=tags&order=published_at%20asc", auth=t)
pages = browse(live, "pages", "formats=html&order=published_at%20asc", auth=t)

# --- write the local rig
call(local, "POST", "session/", {"username": email, "password": password})
KEEP = {"title", "description", "logo", "cover_image", "icon", "accent_color", "locale", "timezone",
        "facebook", "twitter", "threads", "bluesky", "mastodon", "tiktok", "youtube", "instagram", "linkedin",
        "navigation", "secondary_navigation", "meta_title", "meta_description", "og_title", "og_description",
        "twitter_title", "twitter_description", "comments_enabled", "members_signup_access",
        "portal_name", "portal_button", "portal_button_style", "portal_button_icon", "portal_button_signup_text",
        "portal_signup_terms_html", "portal_signup_checkbox_required"}
wanted = [{"key": s["key"], "value": s["value"]} for s in settings if s["key"] in KEEP]
call(local, "PUT", "settings/", {"settings": wanted})
print(f"settings: {len(wanted)} keys")
if theme:
    call(local, "PUT", "custom_theme_settings/", {"custom_theme_settings": [{"key": s["key"], "value": s["value"]} for s in theme]})
    print(f"theme settings: {len(theme)}")
else:
    print("theme settings: not readable with an API key, so the defaults stay (they are copy; edit them at localhost/ghost/ if it matters)")
for kind in ("posts", "pages"):  # replace the rig's content with the live site's
    for item in browse(local, kind, "fields=id"):
        call(local, "DELETE", f"{kind}/{item['id']}/")
FIELDS = ("title", "slug", "html", "status", "published_at", "custom_excerpt", "feature_image",
          "feature_image_alt", "feature_image_caption", "visibility", "featured", "meta_title", "meta_description")
failed = []
for kind, items in (("posts", posts), ("pages", pages)):
    for it in items:
        payload = {k: it.get(k) for k in FIELDS if it.get(k) is not None}
        if it.get("tags"): payload["tags"] = [{"name": tg["name"]} for tg in it["tags"]]
        try:
            call(local, "POST", f"{kind}/?source=html", {kind: [payload]})
        except SystemExit as e:  # one awkward item should not cost the rest of the import
            failed.append(f"{kind[:-1]} {it.get('slug')}: {e}")
    print(f"{kind}: {len(items) - sum(f.startswith(kind[:-1]) for f in failed)} of {len(items)} (drafts included)")
for f in failed: print("skipped", f)
print(f"pulled {live} -> {local}")
if failed: sys.exit(1)  # an honest status for anyone chaining on it
