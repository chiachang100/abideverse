import json
import random
from deep_translator import GoogleTranslator
import streamlit as st

@st.cache_resource
def load_bible():
    with open("./src/data/bible_sample.json", "r", encoding="utf-8") as f:
        return json.load(f)


@st.cache_data
def cloze_text(verse: str):
    # Return cloze-style version of the verse
    words = verse.split()
    hidden = random.sample(words, k=max(1, len(words)//4))
    cloze = " ".join("____" if w in hidden else w for w in words)
    return cloze


def translate_text(text, target="en"):
    try:
        return GoogleTranslator(source="auto", target=target).translate(text)
    except:
        return text
