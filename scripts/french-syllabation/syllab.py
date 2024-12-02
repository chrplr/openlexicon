import re

V = "[aiouy@2EOAe9]"; # vowels
C = "[ptkbdgfsSvzjmnJ]"; # consonants except liquids & semivowels
C1 = "[pkbgfsSvzjJ]"
L = "[lR]"; # liquids 
Y = "[wH]"; # semi-vowels 
X = "[ptkbdgfsSvzjmnJlRwH]"; # all consonants 

def sub_all_matches(word, pattern, repl=r'\1-\2'):        
    while True:
        new_word = re.sub(pattern, repl, word)
        if new_word != word:
            word = new_word
        else:
            break
    return new_word

def syllabify(word):
    rules = [
        f'({V})({V})',
        f'({V})({X}{V})', 
        f'({V}{Y})({Y}{V})',
        f'({V})({C}{V}{Y})',
        f'({V})({L}{Y}{V})',
        f'({V})([td]R{V})',
        f'({V})({C1}{L}{V})',
        f'({V})({X}{X}{V})',
        f'({V})({X}{X}{X}{V})',
        f'({V})({X}{X}{X}{X}{V})',
        f'({V})({X}{X}{X}{X}{X}{V})'
    ]
    
    w = word
    for r in rules:
        w = sub_all_matches(w, r)
    return w
