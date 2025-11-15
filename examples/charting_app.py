import streamlit as st
import pandas as pd

st.title("My Streamlit Charting App")
df = pd.DataFrame({
    'Column 1': [1, 2, 3, 4, 5],
    'Column 2': [10, 20, 30, 40, 50]
})

st.write(df)
st.line_chart(df)
