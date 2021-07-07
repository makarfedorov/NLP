!pip install pymorphy2
!wget 'http://vectors.nlpl.eu/repository/20/180.zip'
!ls
import gensim
import zipfile
with zipfile.ZipFile('180.zip', 'r') as archive:
    stream = archive.open('model.bin')
    model = gensim.models.KeyedVectors.load_word2vec_format(stream, binary=True)
import os
import re
import pymorphy2
from string import punctuation
morph = pymorphy2.MorphAnalyzer()

def tag(m_word):
    tags = {"NOUN":"NOUN", "ADJF":"ADJ", "ADJS":"ADJ", "VERB": "VERB", "INFN": "VERB", "PRTF": "VERB", "PRTS": "VERB","GRND": "VERB", "NUMR": "NUM", "ADVB": "ADJ", "NPRO": "PRON", "PRED": "ADV", "PREP":"ADP", "CONJ": "CCONJ", "PRCL": "PART", "INTJ": "NOUN"}
    try: 
        p_word = morph.parse(m_word)[0]
        norm_word = p_word.normal_form + "_" + tags[p_word.tag.POS]
    except KeyError:  
        norm_word = m_word
    return norm_word

def vec(text):
    changed_words = []
    words = text.split(' ')        
    for word in words:
        ex = 0
        comma = ""
        m_l = []
        if word.endswith("."):
            comma += word[-1]
            word = word[:-1]
        if word in punctuation:
            changed_words.append(word)
            continue
        if len(word) > 0:    
            map1 = morph.parse(word)[0]
            new_word = tag(word)
            if new_word in model:
                x = model.most_similar(new_word)
                for sim in x:
                    mor_w = re.sub("_[A-Z]*", "", sim[0])
                    map2 =  morph.parse(mor_w)[0]
                    for i in map2.lexeme:
                        if i.tag == map1.tag:
                           m_l.append(i.word)
                           changed_words.append(i.word)
                           ex = 1
                           break
                    if ex == 1:
                        break
                if len(m_l) < 1:
                    changed_words.append(word)
                
                        

            else:
                  changed_words.append(word)
            if len(comma) >= 1:
                changed_words[-1] = changed_words[-1] + comma
                      


    return " ".join(changed_words)

with open("Dostoevskiy_Fedor_Besy (1) (1-60).txt", encoding="utf-8") as f:
    text = f.read()

vec_tor = vec(text)
with open("vector_novel_Dostoevsky_Besy.txt", "w", encoding="utf-8") as fw:
    fw.write(vec_tor)
