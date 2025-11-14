from langchain.vectorstores import FAISS
from langchain.embeddings import SentenceTransformerEmbeddings
import json, os

VECTOR_DIR = "vector_store"
BIBLE_JSON = "bible_data/bible_verses.json"
embedding_model = SentenceTransformerEmbeddings(model_name="all-MiniLM-L6-v2")

if os.path.exists(VECTOR_DIR):
    vectorstore = FAISS.load_local(VECTOR_DIR, embedding_model)
else:
    with open(BIBLE_JSON, "r") as f:
        bible_data = json.load(f)
    texts = [f"{v['verse']} ({v['reference']})" for v in bible_data]
    vectorstore = FAISS.from_texts(texts, embedding_model)
    vectorstore.save_local(VECTOR_DIR)
