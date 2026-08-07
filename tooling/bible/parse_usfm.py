#!/usr/bin/env python3
"""
Convert an eBible.org USFM ZIP package into normalized AskRhema JSON.

The output JSON is consumed by build_bible_db.py.

Usage example:

    python tooling/bible/parse_usfm.py \
        --input tooling/bible/downloads/web.zip \
        --translation-id web \
        --name "World English Bible" \
        --language en \
        --output tooling/bible/input/web.json
"""

from __future__ import annotations

import argparse
import json
import re
import tempfile
import zipfile
from pathlib import Path
from typing import Any


# ---------------------------------------------------------------------------
# Canonical Protestant Bible order
# ---------------------------------------------------------------------------

BOOKS = [
    ("genesis", "Genesis", "創世記", "创世记", "OT"),
    ("exodus", "Exodus", "出埃及記", "出埃及记", "OT"),
    ("leviticus", "Leviticus", "利未記", "利未记", "OT"),
    ("numbers", "Numbers", "民數記", "民数记", "OT"),
    ("deuteronomy", "Deuteronomy", "申命記", "申命记", "OT"),
    ("joshua", "Joshua", "約書亞記", "约书亚记", "OT"),
    ("judges", "Judges", "士師記", "士师记", "OT"),
    ("ruth", "Ruth", "路得記", "路得记", "OT"),
    ("1samuel", "1 Samuel", "撒母耳記上", "撒母耳记上", "OT"),
    ("2samuel", "2 Samuel", "撒母耳記下", "撒母耳记下", "OT"),
    ("1kings", "1 Kings", "列王紀上", "列王纪上", "OT"),
    ("2kings", "2 Kings", "列王紀下", "列王纪下", "OT"),
    ("1chronicles", "1 Chronicles", "歷代志上", "历代志上", "OT"),
    ("2chronicles", "2 Chronicles", "歷代志下", "历代志下", "OT"),
    ("ezra", "Ezra", "以斯拉記", "以斯拉记", "OT"),
    ("nehemiah", "Nehemiah", "尼希米記", "尼希米记", "OT"),
    ("esther", "Esther", "以斯帖記", "以斯帖记", "OT"),
    ("job", "Job", "約伯記", "约伯记", "OT"),
    ("psalms", "Psalms", "詩篇", "诗篇", "OT"),
    ("proverbs", "Proverbs", "箴言", "箴言", "OT"),
    ("ecclesiastes", "Ecclesiastes", "傳道書", "传道书", "OT"),
    ("songofsolomon", "Song of Solomon", "雅歌", "雅歌", "OT"),
    ("isaiah", "Isaiah", "以賽亞書", "以赛亚书", "OT"),
    ("jeremiah", "Jeremiah", "耶利米書", "耶利米书", "OT"),
    ("lamentations", "Lamentations", "耶利米哀歌", "耶利米哀歌", "OT"),
    ("ezekiel", "Ezekiel", "以西結書", "以西结书", "OT"),
    ("daniel", "Daniel", "但以理書", "但以理书", "OT"),
    ("hosea", "Hosea", "何西阿書", "何西阿书", "OT"),
    ("joel", "Joel", "約珥書", "约珥书", "OT"),
    ("amos", "Amos", "阿摩司書", "阿摩司书", "OT"),
    ("obadiah", "Obadiah", "俄巴底亞書", "俄巴底亚书", "OT"),
    ("jonah", "Jonah", "約拿書", "约拿书", "OT"),
    ("micah", "Micah", "彌迦書", "弥迦书", "OT"),
    ("nahum", "Nahum", "那鴻書", "那鸿书", "OT"),
    ("habakkuk", "Habakkuk", "哈巴谷書", "哈巴谷书", "OT"),
    ("zephaniah", "Zephaniah", "西番雅書", "西番雅书", "OT"),
    ("haggai", "Haggai", "哈該書", "哈该书", "OT"),
    ("zechariah", "Zechariah", "撒迦利亞書", "撒迦利亚书", "OT"),
    ("malachi", "Malachi", "瑪拉基書", "玛拉基书", "OT"),
    ("matthew", "Matthew", "馬太福音", "马太福音", "NT"),
    ("mark", "Mark", "馬可福音", "马可福音", "NT"),
    ("luke", "Luke", "路加福音", "路加福音", "NT"),
    ("john", "John", "約翰福音", "约翰福音", "NT"),
    ("acts", "Acts", "使徒行傳", "使徒行传", "NT"),
    ("romans", "Romans", "羅馬書", "罗马书", "NT"),
    ("1corinthians", "1 Corinthians", "哥林多前書", "哥林多前书", "NT"),
    ("2corinthians", "2 Corinthians", "哥林多後書", "哥林多后书", "NT"),
    ("galatians", "Galatians", "加拉太書", "加拉太书", "NT"),
    ("ephesians", "Ephesians", "以弗所書", "以弗所书", "NT"),
    ("philippians", "Philippians", "腓立比書", "腓立比书", "NT"),
    ("colossians", "Colossians", "歌羅西書", "歌罗西书", "NT"),
    (
        "1thessalonians",
        "1 Thessalonians",
        "帖撒羅尼迦前書",
        "帖撒罗尼迦前书",
        "NT",
    ),
    (
        "2thessalonians",
        "2 Thessalonians",
        "帖撒羅尼迦後書",
        "帖撒罗尼迦后书",
        "NT",
    ),
    ("1timothy", "1 Timothy", "提摩太前書", "提摩太前书", "NT"),
    ("2timothy", "2 Timothy", "提摩太後書", "提摩太后书", "NT"),
    ("titus", "Titus", "提多書", "提多书", "NT"),
    ("philemon", "Philemon", "腓利門書", "腓利门书", "NT"),
    ("hebrews", "Hebrews", "希伯來書", "希伯来书", "NT"),
    ("james", "James", "雅各書", "雅各书", "NT"),
    ("1peter", "1 Peter", "彼得前書", "彼得前书", "NT"),
    ("2peter", "2 Peter", "彼得後書", "彼得后书", "NT"),
    ("1john", "1 John", "約翰一書", "约翰一书", "NT"),
    ("2john", "2 John", "約翰二書", "约翰二书", "NT"),
    ("3john", "3 John", "約翰三書", "约翰三书", "NT"),
    ("jude", "Jude", "猶大書", "犹大书", "NT"),
    ("revelation", "Revelation", "啟示錄", "启示录", "NT"),
]


# USFM book IDs used by most standard USFM packages.
BOOK_ALIASES = {
    "GEN": "genesis",
    "EXO": "exodus",
    "LEV": "leviticus",
    "NUM": "numbers",
    "DEU": "deuteronomy",
    "JOS": "joshua",
    "JDG": "judges",
    "RUT": "ruth",
    "1SA": "1samuel",
    "2SA": "2samuel",
    "1KI": "1kings",
    "2KI": "2kings",
    "1CH": "1chronicles",
    "2CH": "2chronicles",
    "EZR": "ezra",
    "NEH": "nehemiah",
    "EST": "esther",
    "JOB": "job",
    "PSA": "psalms",
    "PRO": "proverbs",
    "ECC": "ecclesiastes",
    "SNG": "songofsolomon",
    "SOS": "songofsolomon",
    "ISA": "isaiah",
    "JER": "jeremiah",
    "LAM": "lamentations",
    "EZK": "ezekiel",
    "EZE": "ezekiel",
    "DAN": "daniel",
    "HOS": "hosea",
    "JOL": "joel",
    "AMO": "amos",
    "OBA": "obadiah",
    "JON": "jonah",
    "MIC": "micah",
    "NAM": "nahum",
    "HAB": "habakkuk",
    "ZEP": "zephaniah",
    "HAG": "haggai",
    "ZEC": "zechariah",
    "MAL": "malachi",
    "MAT": "matthew",
    "MRK": "mark",
    "MAR": "mark",
    "LUK": "luke",
    "JHN": "john",
    "JOH": "john",
    "ACT": "acts",
    "ROM": "romans",
    "1CO": "1corinthians",
    "2CO": "2corinthians",
    "GAL": "galatians",
    "EPH": "ephesians",
    "PHP": "philippians",
    "PHI": "philippians",
    "COL": "colossians",
    "1TH": "1thessalonians",
    "2TH": "2thessalonians",
    "1TI": "1timothy",
    "2TI": "2timothy",
    "TIT": "titus",
    "PHM": "philemon",
    "HEB": "hebrews",
    "JAS": "james",
    "JAM": "james",
    "1PE": "1peter",
    "2PE": "2peter",
    "1JN": "1john",
    "2JN": "2john",
    "3JN": "3john",
    "JUD": "jude",
    "REV": "revelation",
}


# ---------------------------------------------------------------------------
# USFM text cleanup
# ---------------------------------------------------------------------------

# These are annotation blocks that should not enter Bible search text.
DROP_BLOCK_MARKERS = {
    "f",
    "fe",
    "ef",
    "x",
    "ex",
    "fig",
}


def remove_block_markers(text: str) -> str:
    """
    Remove common USFM footnote/cross-reference blocks.

    Example:

        \\f + \\ft Some note \\f*

    becomes:

        ""
    """

    for marker in DROP_BLOCK_MARKERS:
        pattern = rf"\\{marker}\b.*?\\{marker}\*"
        text = re.sub(
            pattern,
            " ",
            text,
            flags=re.DOTALL,
        )

    return text


def clean_text(text: str) -> str:
    """Convert USFM inline markup to clean Bible text."""

    text = remove_block_markers(text)

    # Remove USFM word attributes, including:
    # \w Paul|strong="G3972"\w*
    # \+w Because|strong="G1223"\+w*
    text = re.sub(
        r"\\\+?w\s+(.*?)\\\+?w\*",
        lambda m: m.group(1).split("|", 1)[0],
        text,
    )

    # Common character-level USFM markers.
    character_markers = [
        "add",
        "addpn",
        "bd",
        "bdit",
        "it",
        "nd",
        "ord",
        "pn",
        "qt",
        "wj",
        "k",
        "lik",
        "lit",
        "sc",
        "sup",
    ]

    for marker in character_markers:
        text = re.sub(
            rf"\\{marker}\*?",
            "",
            text,
        )

    # Remove any remaining simple USFM marker.
    text = re.sub(
        r"\\[A-Za-z0-9]+\*?",
        "",
        text,
    )

    text = text.replace("~", " ")

    text = re.sub(
        r"\s+",
        " ",
        text,
    )

    return text.strip()


# ---------------------------------------------------------------------------
# File discovery
# ---------------------------------------------------------------------------

def find_usfm_files(extracted_dir: Path) -> list[Path]:
    """Find all USFM files in an extracted source package."""

    files = list(extracted_dir.rglob("*.usfm"))
    files.extend(extracted_dir.rglob("*.USFM"))

    return sorted(set(files))


def identify_book(path: Path) -> str | None:
    """
    Identify a canonical book ID from a USFM filename or \\id marker.
    """

    stem = path.stem.upper()

    for code, book_id in BOOK_ALIASES.items():
        if stem.startswith(code):
            return book_id

    text = path.read_text(
        encoding="utf-8-sig",
        errors="replace",
    )

    match = re.search(
        r"^\\id\s+([A-Za-z0-9]+)",
        text,
        flags=re.MULTILINE,
    )

    if match:
        code = match.group(1).upper()
        return BOOK_ALIASES.get(code)

    return None


# ---------------------------------------------------------------------------
# USFM parser
# ---------------------------------------------------------------------------

def parse_usfm_file(
    path: Path,
    translation_id: str,
) -> dict[int, list[dict[str, Any]]]:
    """
    Parse one USFM book.

    Returns:

        {
            1: [
                {"verse": 1, "text": "..."},
                {"verse": 2, "text": "..."},
            ],
            2: [...]
        }
    """

    chapters: dict[int, list[dict[str, Any]]] = {}

    current_chapter: int | None = None
    current_verse: dict[str, Any] | None = None

    lines = path.read_text(
        encoding="utf-8-sig",
        errors="replace",
    ).splitlines()

    for raw_line in lines:
        line = raw_line.strip()

        if not line:
            continue

        # ---------------------------------------------------------------
        # Chapter
        # ---------------------------------------------------------------

        chapter_match = re.match(
            r"^\\c\s+(\d+)",
            line,
        )

        if chapter_match:
            current_chapter = int(
                chapter_match.group(1)
            )

            chapters.setdefault(
                current_chapter,
                [],
            )

            current_verse = None
            continue

        # ---------------------------------------------------------------
        # Verse
        # ---------------------------------------------------------------

        verse_match = re.match(
            r"^\\v\s+(\d+(?:-\d+)?)\s*(.*)$",
            line,
        )

        if verse_match and current_chapter is not None:
            verse_token = verse_match.group(1)
            verse_text = clean_text(verse_match.group(2))

            if "-" in verse_token:
                start, end = map(int, verse_token.split("-"))

                if translation_id in {"cuv_hans", "cuv_hant"}:
                    # CUV source intentionally combines verse ranges.
                    # Preserve the source text in every canonical verse
                    # represented by the range.
                    for verse_number in range(start, end + 1):
                        current_verse = {
                            "verse": verse_number,
                            "text": verse_text,
                        }

                        chapters[current_chapter].append(
                            current_verse
                        )

                    print(
                        f"{translation_id}: "
                        f"{path.name}: "
                        f"chapter {current_chapter}, "
                        f"expanded verse range {verse_token}"
                    )

                    continue

                raise ValueError(
                    f"{translation_id}: {path.name}: "
                    f"verse ranges are not supported: "
                    f"\\v {verse_token}"
                )

            verse_number = int(verse_token)

            current_verse = {
                "verse": verse_number,
                "text": verse_text,
            }

            chapters[current_chapter].append(
                current_verse
            )

            continue

        # ---------------------------------------------------------------
        # Continuation lines
        # ---------------------------------------------------------------

        if (
            current_chapter is None
            or current_verse is None
        ):
            continue

        # Skip pure USFM structural markers.
        if line.startswith("\\"):
            marker_match = re.match(
                r"^\\([A-Za-z0-9]+)",
                line,
            )

            if marker_match:
                marker = marker_match.group(1)

                if marker in DROP_BLOCK_MARKERS:
                    continue

        continuation = clean_text(line)

        if continuation:
            if current_verse["text"]:
                current_verse["text"] += " "

            current_verse["text"] += continuation

    return chapters


# ---------------------------------------------------------------------------
# Translation parser
# ---------------------------------------------------------------------------

def parse_archive(
    zip_path: Path,
    translation_id: str,
    name: str,
    language: str,
) -> dict[str, Any]:

    with tempfile.TemporaryDirectory(
        prefix="askrhema_usfm_"
    ) as temporary_directory:

        extracted_dir = Path(
            temporary_directory
        )

        with zipfile.ZipFile(zip_path) as archive:
            archive.extractall(extracted_dir)

        usfm_files = find_usfm_files(
            extracted_dir
        )

        if not usfm_files:
            raise RuntimeError(
                f"No USFM files found in {zip_path}"
            )

        print(
            f"{translation_id}: "
            f"found {len(usfm_files)} USFM files"
        )

        parsed_books: dict[
            str,
            dict[int, list[dict[str, Any]]]
        ] = {}

        for path in usfm_files:
            book_id = identify_book(path)

            if book_id is None:
                continue

            if book_id in parsed_books:
                raise RuntimeError(
                    f"{translation_id}: duplicate book "
                    f"detected: {book_id}"
                )

            parsed_books[book_id] = parse_usfm_file(
                path,
                translation_id=translation_id,
            )

    # -----------------------------------------------------------------------
    # Require exactly the 66 canonical books.
    # -----------------------------------------------------------------------

    expected_book_ids = {
        book[0]
        for book in BOOKS
    }

    actual_book_ids = set(
        parsed_books.keys()
    )

    missing = expected_book_ids - actual_book_ids

    if missing:
        raise RuntimeError(
            f"{translation_id}: missing books: "
            f"{sorted(missing)}"
        )

    books = []

    for canonical_order, (
        book_id,
        name_en,
        name_zh_hant,
        name_zh_hans,
        testament,
    ) in enumerate(
        BOOKS,
        start=1,
    ):

        chapters = []

        for chapter_number, verses in sorted(
            parsed_books[book_id].items()
        ):
            chapters.append(
                {
                    "chapter": chapter_number,
                    "verses": verses,
                }
            )

        books.append(
            {
                "id": book_id,
                "name_en": name_en,
                "name_zh_hant": name_zh_hant,
                "name_zh_hans": name_zh_hans,
                "testament": testament,
                "canonical_order": canonical_order,
                "chapters": chapters,
            }
        )

    return {
        "translation_id": translation_id,
        "name": name,
        "language_code": language,
        "books": books,
    }


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Convert an AskRhema Bible USFM ZIP "
            "into normalized JSON."
        )
    )

    parser.add_argument(
        "--input",
        type=Path,
        required=True,
        help="USFM ZIP file",
    )

    parser.add_argument(
        "--translation-id",
        required=True,
        choices=[
            "web",
            "cuv_hant",
            "cuv_hans",
        ],
    )

    parser.add_argument(
        "--name",
        required=True,
    )

    parser.add_argument(
        "--language",
        required=True,
    )

    parser.add_argument(
        "--output",
        type=Path,
        required=True,
    )

    args = parser.parse_args()

    if not args.input.exists():
        raise SystemExit(
            f"Input file does not exist: {args.input}"
        )

    result = parse_archive(
        zip_path=args.input,
        translation_id=args.translation_id,
        name=args.name,
        language=args.language,
    )

    args.output.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    args.output.write_text(
        json.dumps(
            result,
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )

    print()
    print(f"Created: {args.output}")


if __name__ == "__main__":
    main()