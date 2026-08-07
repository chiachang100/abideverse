#!/usr/bin/env python3
from pathlib import Path
import argparse, json, sqlite3

ROOT = Path(__file__).resolve().parents[2]
HERE = ROOT / "tooling" / "bible"
INPUT = HERE / "input"
SCHEMA = HERE / "schema.sql"
OUT = ROOT / "assets" / "bible" / "bible.sqlite"
EXPECTED = {"web", "cuv_hant", "cuv_hans"}

def load_sources():
    try:
        import yaml
    except ImportError as e:
        raise SystemExit("Install PyYAML first: python -m pip install pyyaml") from e
    data = yaml.safe_load((HERE / "sources.yaml").read_text(encoding="utf-8")) or {}
    return {x["id"]: x for x in data.get("translations", [])}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=OUT)
    args = parser.parse_args()

    sources = load_sources()
    missing = EXPECTED - sources.keys()
    if missing:
        raise SystemExit(f"Missing manifest entries: {sorted(missing)}")
    blocked = [x for x in EXPECTED if not sources[x].get("redistributable", False)]
    if blocked:
        raise SystemExit(
            "Refusing to build: license/redistribution is not verified for "
            + ", ".join(sorted(blocked))
        )

    data = {}
    for tid in EXPECTED:
        path = INPUT / f"{tid}.json"
        if not path.exists():
            raise SystemExit(f"Missing normalized source: {path}")
        data[tid] = json.loads(path.read_text(encoding="utf-8"))

    books = {}
    verses = {}
    for tid, source in data.items():
        if source.get("translation_id") != tid:
            raise SystemExit(f"{tid}: translation_id mismatch")
        if len(source.get("books", [])) != 66:
            raise SystemExit(f"{tid}: expected 66 books")
        for book in source["books"]:
            books[book["id"]] = book
            for ch in book.get("chapters", []):
                for v in ch.get("verses", []):
                    key = (book["id"], int(ch["chapter"]), int(v["verse"]))
                    verses.setdefault(key, {})[tid] = v["text"]

    for key, texts in verses.items():
        if set(texts) != EXPECTED:
            raise SystemExit(f"{key}: incomplete translation coverage")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    if args.output.exists():
        args.output.unlink()
    db = sqlite3.connect(args.output)
    try:
        db.executescript(SCHEMA.read_text(encoding="utf-8"))
        for tid, s in data.items():
            db.execute("INSERT INTO translations VALUES (?, ?, ?)",
                       (tid, s["name"], s["language_code"]))
        for b in sorted(books.values(), key=lambda x: x["canonical_order"]):
            db.execute(
                "INSERT INTO books VALUES (?, ?, ?, ?, ?, ?)",
                (b["id"], b["canonical_order"], b["name_en"],
                 b["name_zh_hant"], b["name_zh_hans"], b["testament"]))
        for i, key in enumerate(sorted(verses), start=1):
            book, chapter, verse = key
            t = verses[key]
            db.execute(
                "INSERT INTO verses VALUES (?, ?, ?, ?, ?, ?, ?)",
                (i, book, chapter, verse, t["web"], t["cuv_hant"], t["cuv_hans"]))
            db.execute("INSERT INTO verses_fts_en VALUES (?, ?)", (i, t["web"]))
            db.execute("INSERT INTO verses_fts_zh VALUES (?, ?)",
                       (i, t["cuv_hant"] + " " + t["cuv_hans"]))
        db.commit()
    finally:
        db.close()
    print(f"Created {args.output}")

if __name__ == "__main__":
    main()
