PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS translations (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    language_code TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS books (
    id TEXT PRIMARY KEY,
    canonical_order INTEGER NOT NULL UNIQUE,
    name_en TEXT NOT NULL,
    name_zh_hant TEXT NOT NULL,
    name_zh_hans TEXT NOT NULL,
    testament TEXT NOT NULL CHECK (testament IN ('OT', 'NT'))
);

CREATE TABLE IF NOT EXISTS verses (
    id INTEGER PRIMARY KEY,
    book_id TEXT NOT NULL,
    chapter INTEGER NOT NULL CHECK (chapter > 0),
    verse INTEGER NOT NULL CHECK (verse > 0),
    web TEXT,
    cuv_hant TEXT,
    cuv_hans TEXT,
    FOREIGN KEY (book_id) REFERENCES books(id),
    UNIQUE(book_id, chapter, verse)
);

CREATE INDEX IF NOT EXISTS idx_verses_book_chapter
ON verses(book_id, chapter, verse);

CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts_en USING fts5(
    verse_id UNINDEXED, text
);

CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts_zh USING fts5(
    verse_id UNINDEXED, text, tokenize='trigram'
);
