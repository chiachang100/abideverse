#!/usr/bin/env python3
"""
Download the Bible USFM source packages used by AskRhema.

Run from the repository root:

    python tooling/bible/download_sources.py

The downloaded files are build inputs. They are not Flutter runtime assets.
"""

from __future__ import annotations

from pathlib import Path
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[2]

DOWNLOAD_DIR = ROOT / "tooling" / "bible" / "downloads"


SOURCES = {
    "web": "https://ebible.org/Scriptures/engwebp_usfm.zip",
    "cuv_hant": "https://ebible.org/Scriptures/cmn-cu89t_usfm.zip",
    "cuv_hans": "https://ebible.org/Scriptures/cmn-cu89s_usfm.zip",
}


def download(name: str, url: str) -> Path:
    """Download one USFM ZIP package."""

    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)

    destination = DOWNLOAD_DIR / f"{name}.zip"

    request = Request(
        url,
        headers={
            "User-Agent": "AskRhema Bible build tool",
        },
    )

    print(f"Downloading {name}")
    print(f"  URL: {url}")

    with urlopen(request, timeout=120) as response:
        data = response.read()

    # ZIP files begin with PK.
    if not data.startswith(b"PK"):
        raise RuntimeError(
            f"{name}: downloaded content does not appear to be a ZIP archive."
        )

    destination.write_bytes(data)

    print(
        f"  Saved: {destination} "
        f"({len(data):,} bytes)"
    )

    return destination


def main() -> None:
    print("AskRhema Bible source downloader")
    print("=" * 40)

    for name, url in SOURCES.items():
        download(name, url)

    print()
    print("All Bible source packages downloaded successfully.")


if __name__ == "__main__":
    main()