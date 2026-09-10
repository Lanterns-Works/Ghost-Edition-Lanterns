# Test content for the local rig (dev/rig.sh): one Admin-API post payload per line. Emerson's
# Essays from Project Gutenberg (public domain, and plainly not em's writing): Self-Reliance
# trimmed to ~2,500 words for the reading column, the others as stubs, dated apart, so the index
# has 12 posts and pagination (10 a page) shows. The eye-gate still wants a real essay.
import json, re, datetime, pathlib, sys, urllib.request
cache = pathlib.Path(sys.argv[1]) / "emerson.txt"
if not cache.exists():
    urllib.request.urlretrieve("https://www.gutenberg.org/cache/epub/16643/pg16643.txt", cache)
txt = cache.read_text(encoding="utf-8")
lines = txt.splitlines()
# essay headings are the all-caps lines in the body (after the contents block, before the footnotes)
titles = ["HISTORY","SELF-RELIANCE","COMPENSATION","SPIRITUAL LAWS","LOVE","FRIENDSHIP","PRUDENCE","HEROISM","THE OVER-SOUL","CIRCLES","INTELLECT","ART"]
starts = {}
for i, l in enumerate(lines):
    t = l.strip().rstrip(".")
    if t in titles and i > 1500 and t not in starts:
        starts[t] = i
order = sorted(starts.items(), key=lambda kv: kv[1])
def body(i, j):
    chunk = "\n".join(lines[i+1:j])
    chunk = re.sub(r"\[\d+\]", "", chunk)            # footnote markers
    paras = [re.sub(r"\s+", " ", p).strip() for p in re.split(r"\n\s*\n", chunk)]
    return [p for p in paras if p and not p.isupper() and not p.startswith("[Footnote")]
def html(paras, full):
    out = []
    for k, p in enumerate(paras):
        if k == 0 and len(p) < 400 and full:           # the verse epigraph reads as a blockquote
            out.append("<blockquote><p>" + p.replace(" / ", "<br>") + "</p></blockquote>")
        elif full and k in (12, 30) :                  # two headings so the h2 style gets exercised
            out.append("<h2>" + p.split(".")[0][:60] + "</h2><p>" + p + "</p>")
        else:
            out.append("<p>" + p + "</p>")
    return "\n".join(out)
base = datetime.datetime(2026, 9, 1, 9, 0)
# six essays whose headings the file sets differently: stub them from the tail of Self-Reliance
# so the index passes posts_per_page (10) and pagination renders.
sr_i = starts["SELF-RELIANCE"]; sr_j = [j for _, j in order if j > sr_i][0] if any(j > sr_i for _, j in order) else len(lines)
tail = body(sr_i, sr_j)[60:]
for k, t in enumerate([t for t in titles if t not in starts]):
    order.append((t, None)); starts[t] = ("stub", tail[k*3:(k*3)+3])
for n, (title, i) in enumerate(order):
    if i is None:
        paras = starts[title][1]; full = False
        print(json.dumps({"posts": [{"title": title.title(), "html": html(paras, False), "status": "published",
            "published_at": (base - datetime.timedelta(days=3*n)).isoformat() + ".000Z",
            "custom_excerpt": paras[0][:280].rsplit(" ", 1)[0] + "."}]}))
        continue
    j = order[n+1][1] if n+1 < len(order) else len(lines)
    paras = body(i, j)
    full = title == "SELF-RELIANCE"
    if full:
        out, n_words = [], 0
        for q in paras:
            out.append(q); n_words += len(q.split())
            if n_words > 2500: break
        paras = out
    else:
        paras = paras[:3]
    post = {
        "title": title.title().replace("The Over-Soul", "The Over-Soul"),
        "html": html(paras, full),
        "status": "published",
        "published_at": (base - datetime.timedelta(days=3*n)).isoformat() + ".000Z",
        "custom_excerpt": (paras[1] if full else paras[0])[:280].rsplit(" ", 1)[0] + ".",
    }
    print(json.dumps({"posts": [post]}))
