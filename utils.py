import json
import random
from deep_translator import GoogleTranslator

def load_bible():
    with open("data/bible_sample.json", "r", encoding="utf-8") as f:
        return json.load(f)


def cloze_text(verse: str):
    words = verse.split()
    hidden = random.sample(words, k=max(1, len(words)//4))
    cloze = " ".join("____" if w in hidden else w for w in words)
    return cloze


def translate_text(text, target="zh"):
    try:
        return GoogleTranslator(source="auto", target=target).translate(text)
    except:
        return text
