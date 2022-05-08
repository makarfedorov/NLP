import numpy as np
from itertools import combinations
from nltk.tokenize import sent_tokenize, word_tokenize 
nltk.download('punkt')
from pymorphy2 import MorphAnalyzer
from collections import defaultdict
import pandas as pd
from string import punctuation
filter = list(punctuation + "—»«...–")
parser = MorphAnalyzer ()
def preprocess (input_text):
    '''функция для предобработки текста'''
    tokenized_text = word_tokenize (input_text.lower())
    clean_text = [word for word in tokenized_text if word not in filter]
    lemmatized_text = [parser.parse(word)[0].normal_form for word in clean_text]
    return lemmatized_text

def co_occurrence(sentences, window_size):
    '''Функция для построения матрицы совместной встречмости слов с 
    необработанными частотностями'''
    d = defaultdict(int)
    vocab = set()
    if type(sentences) is str:
        sentences = sent_tokenize(sentences)
    for text in sentences:
        # preprocessing 
        tokenized_text = word_tokenize(text)
        text = preprocess(text)
        # iterate over sentences
        for i in range(len(text)):
            token = text[i]
            vocab.add(token)  # add to vocab
            next_token = text[i+1 : i+1+window_size]
            for t in next_token:
                key = tuple( sorted([t, token]) )
                d[key] += 1
    
    # formulate the dictionary into dataframe
    vocab = sorted(vocab) # sort vocab
    df = pd.DataFrame(data=np.zeros((len(vocab), len(vocab)), dtype=np.int16),
                      index=vocab,
                      columns=vocab)
    for key, value in d.items():
        df.at[key[0], key[1]] = value
        df.at[key[1], key[0]] = value
    return df
