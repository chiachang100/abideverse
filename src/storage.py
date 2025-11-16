import sqlite3

DB_PATH = "tmp/abideverse.db"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()

    c.execute("""
    CREATE TABLE IF NOT EXISTS memory_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse TEXT,
        cloze TEXT,
        attempts INTEGER DEFAULT 0,
        correct INTEGER DEFAULT 0
    )
    """)

    conn.commit()
    conn.close()


def add_memory_card(verse, cloze):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO memory_cards (verse, cloze) VALUES (?, ?)", (verse, cloze))
    conn.commit()
    conn.close()


def get_cards():
    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute("SELECT * FROM memory_cards").fetchall()
    conn.close()
    return rows
