import requests, json, os, re, time

ROOT = os.path.dirname(os.path.abspath(__file__))
TAGS_FILE = os.path.join(ROOT, "tags.json")

def get_slugs():
    slugs = set()
    for dirpath, dirnames, filenames in os.walk(ROOT):
        for f in filenames:
            if f.endswith(".java"):
                m = re.match(r'^\d{4}-(.+)\.java$', f)
                if m:
                    slugs.add(m.group(1))
    return slugs

def fetch_meta(slug):
    query = {
        "query": """
            query questionMeta($titleSlug: String!) {
              question(titleSlug: $titleSlug) {
                difficulty
                topicTags { name }
              }
            }""",
        "variables": {"titleSlug": slug}
    }
    resp = requests.post("https://leetcode.com/graphql/", json=query,
                          headers={"Content-Type": "application/json", "Referer": "https://leetcode.com"})
    data = resp.json()

    if data.get("errors"):
        raise ValueError(f"GraphQL errors: {data['errors']}")

    question = (data.get("data") or {}).get("question")
    if question is None:
        raise ValueError("No question data returned (bad slug or removed problem)")

    tags = ", ".join(t["name"] for t in (question.get("topicTags") or []))
    difficulty = question.get("difficulty", "")
    return {"tags": tags, "difficulty": difficulty}

def save(tags_db):
    with open(TAGS_FILE, "w", encoding="utf-8") as f:
        json.dump(tags_db, f, indent=2)

def main():
    tags_db = {}
    if os.path.exists(TAGS_FILE):
        with open(TAGS_FILE, "r", encoding="utf-8") as f:
            tags_db = json.load(f)

    slugs = get_slugs()
    new_count, error_count = 0, 0
    for slug in sorted(slugs):
        existing = tags_db.get(slug)
        # Skip only if already in the new dict format (upgrades old string-format entries)
        if isinstance(existing, dict):
            continue
        try:
            meta = fetch_meta(slug)
            tags_db[slug] = meta
            print(f"{slug}: {meta['difficulty']} | {meta['tags']}")
            new_count += 1
        except Exception as e:
            print(f"SKIPPED {slug}: {e}")
            error_count += 1
        save(tags_db)
        time.sleep(0.5)

    print(f"\nDone. Fetched {new_count} new, {error_count} skipped, {len(tags_db)} total cached.")

if __name__ == "__main__":
    main()