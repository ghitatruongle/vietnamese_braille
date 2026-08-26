import json
import sys
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")


def get(url):
    req = urllib.request.Request(
        url, headers={"User-Agent": "ci", "Accept": "application/vnd.github+json"}
    )
    return json.load(urllib.request.urlopen(req, timeout=30))


runs = get(
    "https://api.github.com/repos/ghitatruongle/vietnamese_braille/actions/runs?event=push&per_page=6"
)
cand = [
    r
    for r in runs["workflow_runs"]
    if r["head_sha"].startswith("db1e7c2") and r["name"] == "Vietnamese Braille CI"
]
if not cand:
    print("CI run for db1e7c2 chua xuat hien")
    sys.exit()
run = cand[0]
print("OVERALL:", run["status"], "/", run["conclusion"])
jobs = get(run["jobs_url"] + "?per_page=30")
for j in jobs["jobs"]:
    print(" ", j["status"], j["conclusion"], "|", j["name"])
