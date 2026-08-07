# Bible database tooling

This is build-time tooling. It does not download Bible text.

Normalized source JSON files belong in `tooling/bible/input/` as:
`web.json`, `cuv_hant.json`, and `cuv_hans.json`.

Each file must contain `translation_id`, `name`, `language_code`, and 66
canonical books. Each book contains `id`, `canonical_order`, `name_en`,
`name_zh_hant`, `name_zh_hans`, `testament`, and chapter/verse text.

The builder refuses to generate a database unless every configured translation
is explicitly marked `redistributable: true` in `sources.yaml`.

Run:
- `python tooling/bible/build_bible_db.py`
- `python tooling/bible/validate_bible_db.py`

Output:
  `assets/bible/bible.sqlite`

---
