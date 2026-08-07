# Bible Sources

I found a good common source for all three translations: `eBible.org`.

- English: **World English Bible (WEBP)** — `eBible.org` explicitly states it is public domain and permits redistribution.
- Traditional Chinese: **新標點和合本 (CUVt)** — `eBible.org` identifies it as public domain and provides a complete USFM download.
- Simplified Chinese: **新标点和合本 (CUVs)** — `eBible.org` identifies it as public domain and provides a complete USFM download.

This is substantially better than relying on random GitHub JSON repositories.

- [WEB source & downloads](https://ebible.org/bible/details.php?all=1&id=engwebp&utm_source=chatgpt.com)
- [CUV Traditional source & downloads](https://ebible.org/bible/details.php?all=1&id=cmn-cu89t&utm_source=chatgpt.com)
- [CUV Simplified source & downloads](https://ebible.org/bible/details.php?all=1&id=cmn-cu89s&utm_source=chatgpt.com)

The exact source files

We'll use the following Python script to download the three ZIP files:

- `python tooling/bible/download_sources.py`

```text
tooling/bible/downloads/
├── web.zip
├── cuv_hant.zip
└── cuv_hans.zip
```

from:

- https://ebible.org/Scriptures/engwebp_usfm.zip
- https://ebible.org/Scriptures/cmn-cu89t_usfm.zip
- https://ebible.org/Scriptures/cmn-cu89s_usfm.zip

The eBible directory confirms these `USFM` packages are available.

One correction to my previous implementation

The earlier build_bible_db.py expected already-normalized JSON. That's not ideal.

We should instead make the pipeline:

```text
eBible.org USFM
       │
       ▼
download_sources.py
       │
       ▼
parse_usfm.py - USFM parser
       │
       ▼
normalized Bible records
       │
       ▼
SQLite builder
       │
       ▼
assets/bible/bible.sqlite
       │
       ▼
validator
```

So the next code we should add is:

- `tooling/bible/download_sources.py`
- `tooling/bible/usfm_to_json.py`

and then modify:

`tooling/bible/build_bible_db.py`

to consume those generated records.

I would not generate bible.sqlite yet until that USFM parser has been tested against all three 66-book packages. That's the right next engineering step rather than generating a database we haven't validated.

One note: I attempted to package the updated source files into another ZIP in this turn, but the file-generation environment didn't complete successfully, so I won't pretend that ZIP exists. The earlier ZIP remains the valid download.

---
## Run the tools

### Download ZIP files

- `python tooling/bible/download_sources.py`


- Convert an eBible.org English USFM ZIP package into normalized AskRhema JSON.
- 
```text
python tooling/bible/parse_usfm.py \
  --input tooling/bible/downloads/web.zip \
  --translation-id web \
  --name "World English Bible" \
  --language en \
  --output tooling/bible/input/web.json
```

- For Windows CMD:
```text
python tooling\bible\parse_usfm.py --input tooling/bible/downloads/web.zip  --translation-id web --name "World English Bible" --language en --output tooling/bible/input/web.json

```

- Convert an eBible.org Traditional Chinese USFM ZIP package into normalized AskRhema JSON.

```text
python tooling/bible/parse_usfm.py \
  --input tooling/bible/downloads/cuv_hant.zip \
  --translation-id cuv_hant \
  --name "Chinese Union Version (Traditional)" \
  --language zh-Hant \
  --output tooling/bible/input/cuv_hant.json
```

- For Windows CMD:
```text
python tooling\bible\parse_usfm.py --input tooling/bible/downloads/cuv_hant.zip  --translation-id cuv_hant --name "Chinese Union Version (Traditional)" --language zh-Hant --output tooling/bible/input/cuv_hant.json

```

- Convert an eBible.org Simplified Chinese USFM ZIP package into normalized AskRhema JSON.

```text
python tooling/bible/parse_usfm.py \
  --input tooling/bible/downloads/cuv_hans.zip \
  --translation-id cuv_hans \
  --name "Chinese Union Version (Simplified)" \
  --language zh-Hans \
  --output tooling/bible/input/cuv_hans.json
```

- For Windows CMD:
```text
python tooling\bible\parse_usfm.py --input tooling/bible/downloads/cuv_hans.zip  --translation-id cuv_hans --name "Chinese Union Version (Simplified)" --language zh-Hans --output tooling/bible/input/cuv_hans.json

```

- You should then see:

```text
tooling/bible/input/
├── web.json
├── cuv_hant.json
└── cuv_hans.json
```

---
## Build SQLite File

### Step 1 — Verify the generated JSON
Before creating SQLite, run:

```bash
python -c "import json; from pathlib import Path; [print(p, len(json.loads(p.read_text(encoding='utf-8'))['books'])) for p in Path('tooling/bible/input').glob('*.json')]"
```

You should get:

```text
web.json 66
cuv_hant.json 66
cuv_hans.json 66
```

Then let's check the verse counts:

```bash
python -c "import json; from pathlib import Path; [print(p.name, sum(len(c['verses']) for b in json.loads(p.read_text(encoding='utf-8'))['books'] for c in b['chapters'])) for p in Path('tooling/bible/input').glob('*.json')]"
```

We should expect roughly 31,000+ verses for each translation.

```text
cuv_hans.json 31021
cuv_hant.json 31021
web.json 31103
```

### Step 2 — Build SQLite

Assuming those checks pass:

`python tooling/bible/build_bible_db.py`

This should create:

```text
assets/
└── bible/
    └── bible.sqlite
```

### Step 3 — Validate it

Immediately run:

`python tooling/bible/validate_bible_db.py`

We want this to verify at least:

- 66 books
- ~31k verses
- English text present
- Traditional Chinese text present
- Simplified Chinese text present
- Genesis 1:1
- John 3:16
- FTS5 English index
- FTS5 Chinese index
- no missing translation data

But there is one thing I want to fix before you build

---
## Bible source ingestion layer

The next step should be the actual source ingestion layer, and I’ve now verified the source choice more carefully.

### Source decision is now solid

For AskRhema, I recommend:

| Translation	| Source	| License |
|-------------|---------|---------|
| English	| World English Bible (WEB)	| Public domain |
| 繁體中文	| 新標點和合本 (CUVt)	| Public domain |
| 简体中文	| 新标点和合本 (CUVs)	| Public domain |

`eBible.org` explicitly identifies **WEB as public domain** and allows copying, publishing, distributing, and redistributing it. It also notes that **“World English Bible”** is a trademark, so we shouldn't rename a modified WEB text as WEB.

The **two Chinese editions are also explicitly identified as Public Domain** by eBible.org.

Most importantly, `eBible.org` provides USFM packages for both Chinese editions, and WEB has a USFM package as well.

So I would lock this in as the AskRhema Bible source strategy.

### The pipeline should now look like this

```text
eBible.org
    │
    ├── engwebp_usfm.zip
    ├── cmn-cu89t_usfm.zip
    └── cmn-cu89s_usfm.zip
              │
              ▼
    tooling/bible/downloads/
              │
              ▼
       USFM parser
              │
              ▼
    normalized Bible records
              │
              ▼
       SQLite builder
              │
              ▼
    assets/bible/bible.sqlite
              │
              ▼
         validator
              │
              ▼
       Flutter / AskRhema
```

I do not recommend putting the raw USFM files into Flutter assets.

They're build inputs. The only runtime asset should be:

`assets/bible/bible.sqlite`

---
