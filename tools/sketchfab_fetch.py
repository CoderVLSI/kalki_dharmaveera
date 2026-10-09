"""Search / download CC0 + CC-BY models via the official Sketchfab Data API.
Needs SKETCHFAB_API_TOKEN in the environment (never commit it) and network access to
api.sketchfab.com + media hosts. See docs/design/SKETCHFAB_PLAN.md.

  python3 tools/sketchfab_fetch.py search "rigged warrior" [--animated] [--max-faces 30000]
  python3 tools/sketchfab_fetch.py get <uid>
"""
import os, sys, json, argparse, urllib.request, urllib.parse, zipfile, io, datetime

API = "https://api.sketchfab.com/v3"
ROOT = os.path.join(os.path.dirname(__file__), "..")
OK_LICENSES = {"cc0", "by"}          # CC0 and CC-BY only (slugs from the API)


def call(url, need_token=True):
    tok = os.environ.get("SKETCHFAB_API_TOKEN")
    if need_token and not tok:
        sys.exit("SKETCHFAB_API_TOKEN is not set")
    req = urllib.request.Request(url, headers={"Authorization": f"Token {tok}"} if tok else {})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def search(a):
    q = {"q": a.query, "type": "models", "downloadable": "true", "count": 24, "sort_by": "-likeCount"}
    if a.animated: q["animated"] = "true"
    if a.max_faces: q["max_face_count"] = a.max_faces
    res = call(f"{API}/search?{urllib.parse.urlencode(q)}", need_token=False)   # search works anonymously
    for m in res.get("results", []):
        # search results omit the licence: look each model up (also anonymous)
        meta = call(f"{API}/models/{m['uid']}", need_token=False)
        lic = (meta.get("license") or {}).get("slug", "?")
        flag = "OK " if lic in OK_LICENSES else "NO "
        print(f'{flag}{m["uid"]}  {lic:6} faces={m.get("faceCount")}  anim={m.get("animationCount", 0)}  "{m["name"]}" by {m["user"]["displayName"]}')


def get(a):
    meta = call(f"{API}/models/{a.uid}")
    lic = (meta.get("license") or {}).get("slug", "?")
    if lic not in OK_LICENSES:
        sys.exit(f"Refusing: licence '{lic}' is not CC0/CC-BY")
    dl = call(f"{API}/models/{a.uid}/download")["gltf"]["url"]
    data = urllib.request.urlopen(dl, timeout=300).read()
    out = os.path.join(ROOT, "assets", "source", "sketchfab", a.uid)
    os.makedirs(out, exist_ok=True)
    zipfile.ZipFile(io.BytesIO(data)).extractall(out)
    line = (f'- "{meta["name"]}" by {meta["user"]["displayName"]} ({meta["viewerUrl"]}), '
            f'licence {meta["license"]["label"]}, fetched {datetime.date.today()}\n')
    with open(os.path.join(ROOT, "docs", "ATTRIBUTION.md"), "a") as f:
        f.write(line)
    print("downloaded to", out); print(line)


p = argparse.ArgumentParser(); sub = p.add_subparsers(dest="cmd", required=True)
s = sub.add_parser("search"); s.add_argument("query"); s.add_argument("--animated", action="store_true"); s.add_argument("--max-faces", type=int)
g = sub.add_parser("get"); g.add_argument("uid")
a = p.parse_args()
search(a) if a.cmd == "search" else get(a)
