import json
import os
import urllib.parse
import urllib.request
from pathlib import Path

import google.auth
from google.auth.transport.requests import Request


API_KEY = os.environ["NEWSDATA_API_KEY"]
PROJECT_ID = "ahmed-news-app-2026"
TOPIC = "news_updates"

SEEN_FILE = Path(__file__).with_name("seen_articles.json")
NEWS_URL = "https://newsdata.io/api/1/latest"


def load_seen_articles():
    if not SEEN_FILE.exists():
        return set()

    try:
        with SEEN_FILE.open("r", encoding="utf-8") as file:
            return set(json.load(file))
    except (json.JSONDecodeError, OSError):
        return set()


def save_seen_articles(article_ids):
    # Keep a limited history to avoid an unbounded file.
    article_ids = list(article_ids)[-2000:]

    with SEEN_FILE.open("w", encoding="utf-8") as file:
        json.dump(article_ids, file, ensure_ascii=False, indent=2)


def fetch_articles():
    params = {
        "apikey": API_KEY,
        "country": "eg",
        "language": "en,ar",
        "image": "1",
        "size": "10",
    }

    url = f"{NEWS_URL}?{urllib.parse.urlencode(params)}"

    request = urllib.request.Request(
        url,
        headers={"User-Agent": "NewsApp-GitHubActions/1.0"},
    )

    with urllib.request.urlopen(request, timeout=30) as response:
        data = json.loads(response.read().decode("utf-8"))

    if data.get("status") != "success":
        raise RuntimeError("NewsData API did not return success.")

    return data.get("results", [])


def get_access_token():
    credentials, _ = google.auth.default(
        scopes=["https://www.googleapis.com/auth/firebase.messaging"]
    )

    credentials.refresh(Request())
    return credentials.token


def send_notification(access_token, title, body, article_url):
    url = (
        f"https://fcm.googleapis.com/v1/projects/"
        f"{PROJECT_ID}/messages:send"
    )

    payload = {
        "message": {
            "topic": TOPIC,
            "notification": {
                "title": title[:100],
                "body": body[:200],
            },
            "data": {
                "url": article_url,
                "type": "news_update",
            },
            "android": {
                "priority": "high",
                "notification": {
                    "channel_id": "news_channel",
                },
            },
        }
    }

    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    with urllib.request.urlopen(request, timeout=30) as response:
        result = json.loads(response.read().decode("utf-8"))

    print("Notification sent:", result.get("name", "success"))


def main():
    articles = fetch_articles()
    seen = load_seen_articles()

    # First run: mark existing articles as known, without notifying.
    if not seen:
        for article in articles:
            article_id = article.get("article_id")
            if article_id:
                seen.add(article_id)

        save_seen_articles(seen)
        print(f"Initialized history with {len(seen)} existing articles.")
        return

    new_articles = []

    for article in articles:
        article_id = article.get("article_id")

        if article_id and article_id not in seen:
            new_articles.append(article)
            seen.add(article_id)

    if not new_articles:
        print("No new articles.")
        save_seen_articles(seen)
        return

    access_token = get_access_token()

    # Send at most three notifications per run.
    for article in new_articles[:3]:
        title = article.get("title") or "New article"
        body = article.get("description") or "Open the app to read the latest news."
        article_url = article.get("link") or ""

        send_notification(
            access_token,
            title,
            body,
            article_url,
        )

    save_seen_articles(seen)
    print(f"Processed {len(new_articles[:3])} new articles.")


if __name__ == "__main__":
    main()
