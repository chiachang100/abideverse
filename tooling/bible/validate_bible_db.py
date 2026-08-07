#!/usr/bin/env python3
from pathlib import Path
import argparse, sqlite3

ROOT = Path(__file__).resolve().parents[2]
DEFAULT = ROOT / "assets" / "bible" / "bible.sqlite"

def check(ok, msg):
    if not ok:
        raise SystemExit("VALIDATION FAILED: " + msg)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--database", type=Path, default=DEFAULT)
    args = p.parse_args()
    check(args.database.exists(), f"missing {args.database}")
    db = sqlite3.connect(args.database)
    try:
        translations = {r[0] for r in db.execute("SELECT id FROM translations")}
        check(translations == {"web", "cuv_hant", "cuv_hans"}, "translation set")
        books = db.execute("SELECT COUNT(*) FROM books").fetchone()[0]
        verses = db.execute("SELECT COUNT(*) FROM verses").fetchone()[0]
        check(books == 66, f"book count={books}")
        check(verses > 30000, f"verse count={verses}")
        missing = db.execute(
            "SELECT COUNT(*) FROM verses WHERE web IS NULL OR cuv_hant IS NULL OR cuv_hans IS NULL"
        ).fetchone()[0]
        check(missing == 0, f"missing translation text={missing}")
        for table in ("verses_fts_en", "verses_fts_zh"):
            db.execute(f"SELECT * FROM {table} LIMIT 1")
        for book, ch, verse in (("genesis",1,1), ("john",3,16)):
            row = db.execute(
                "SELECT 1 FROM verses WHERE book_id=? AND chapter=? AND verse=?",
                (book,ch,verse)).fetchone()
            check(row is not None, f"missing {book} {ch}:{verse}")
        print(f"Bible database validation PASSED: {books} books, {verses} verses")
    finally:
        db.close()

if __name__ == "__main__":
    main()
