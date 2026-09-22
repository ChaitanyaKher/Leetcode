import requests, os, time

LEETCODE_SESSION = os.environ.get("LEETCODE_SESSION")
CSRF_TOKEN = os.environ.get("LEETCODE_CSRF_TOKEN")

if not LEETCODE_SESSION or not CSRF_TOKEN:
    raise SystemExit("Set LEETCODE_SESSION and LEETCODE_CSRF_TOKEN environment variables first.")

HEADERS = {"Content-Type": "application/json", "Referer": "https://leetcode.com",
           "x-csrftoken": CSRF_TOKEN, "User-Agent": "Mozilla/5.0"}
COOKIES = {"LEETCODE_SESSION": LEETCODE_SESSION, "csrftoken": CSRF_TOKEN}

def get_accepted_java_submissions():
    submissions, offset, limit = {}, 0, 20
    while True:
        resp = requests.get(f"https://leetcode.com/api/submissions/?offset={offset}&limit={limit}",
                             headers=HEADERS, cookies=COOKIES)
        data = resp.json()
        subs = data.get("submissions_dump", [])
        if not subs:
            break
        for s in subs:
            if s.get("status_display") == "Accepted" and s.get("lang") == "java":
                slug = s["title_slug"]
                if slug not in submissions:  # keep newest (first seen)
                    submissions[slug] = s
        if not data.get("has_next"):
            break
        offset += limit
        time.sleep(1)
    return submissions

def main():
    print("Fetching accepted Java submissions...")
    subs = get_accepted_java_submissions()
    print(f"Found {len(subs)} unique accepted Java problems.")

    added, skipped = 0, 0
    for slug, s in subs.items():
        code = s["code"]
        qid = int(s["question_id"])

        padded = f"{qid:04d}"
        range_start = ((qid - 1) // 100) * 100 + 1
        range_folder = f"{range_start:04d}-{range_start+99:04d}"
        problem_folder = f"{padded}-{slug}"
        file_name = f"{padded}-{slug}.java"
        dest_dir = os.path.join(range_folder, problem_folder)

        os.makedirs(dest_dir, exist_ok=True)
        dest_path = os.path.join(dest_dir, file_name)

        if not os.path.exists(dest_path):
            with open(dest_path, "w", encoding="utf-8") as f:
                f.write(code)
            print(f"Added {file_name}")
            added += 1
        else:
            skipped += 1

    print(f"\nDone. Added {added}, skipped {skipped} already-existing files.")

if __name__ == "__main__":
    main()