#! /usr/bin/env python3
# Time-stamp: <2018-11-07 11:39:39 cp983411>

import dico
import pandas as pd
import os.path as op
import pprint as pp

LEXIQUE = 'Lexique382/Lexique382.txt'
FREQFILE = 'ortho-freql.txt'


def create_freq_file(lexique_path, outputfile):
    """ extract columns 'ortho' and 'freqlivres' from Lexique """
    a = pd.read_csv(lexique_path, sep='\t')

    b = a[['1_ortho', '10_freqlivres']].rename(columns={'1_ortho': 'ortho',
                                                        '10_freqlivres': 'freql'})
    # put a threshold on freq (?)
    # b = b[b.freql > .2]
    b.to_csv(outputfile, sep='\t', index=False)


def save_dict(d, filename):
    """ save the dictionary 'd' as a csv file (tab separated) with two columns: key, value. """
    pd.DataFrame.from_dict(d, orient='index').sort_values(by=0, ascending=False).to_csv(filename, sep='\t', header=False, float_format='%f')


if __name__ == '__main__':
    if not op.isfile(FREQFILE):
        create_freq_file(LEXIQUE, FREQFILE)

    mydic = dico.dico()
    mydic.import_csv(FREQFILE)

    letters = mydic.letter_distribution()
    # pp.pprint(letters)
    save_dict(letters, 'letters.csv')

    bigrams = mydic.bigram_distribution()
    # pp.pprint(bigrams)
    save_dict(bigrams, 'bigrams.csv')

    openbigrams = mydic.openbigram_distribution()
    #pp.pprint(openbigrams)
    save_dict(openbigrams, 'openbigrams.csv')

    trigrams = mydic.trigram_distribution()
    # pp.pprint(trigrams)
    save_dict(trigrams, 'trigrams.csv')

    quadrigrams = mydic.quadrigram_distribution()
    # pp.pprint(quadrigrams)
    save_dict(quadrigrams, 'quadrigrams.csv')
