This folder and its subfolders are part of the [OpenLexicon](http://chrplr.github.io/openlexicon) and [Lexique](http://www.lexique.org) projects.

Important note: As the source tables take up a lot of disk space (>100MB), they are not included in the [github repository](https://github.com/chrplr/openlexicon). To get them, you need to download and unzip the file [databases.zip](http://lexique.org/databases.zip) 

The `.tsv` and `.csv` files are plain text files that can be easily important in to R, MATLAB or Python. To open them with Excel, check out <https://rievent.zendesk.com/hc/en-us/articles/360000029172-FAQ-How-do-I-open-a-tsv-file-in-Excel->

If you want to contribute, adding or correcting some databases, please contact `christophe@pallier.org` and `boris.new@gmail.com`

# Currently available databases #

## Lexique382 ##

_Lexique382_ est une base de données lexicales du français qui fournit pour ~140000 mots du français: les représentations orthographiques et phonémiques, les lemmes associés, la syllabation, la catégorie grammaticale, le genre et le nombre, les fréquences dans un corpus de livres et dans un corpus de sous-titres de filems, etc. 

 - Table: [databases/Lexique382.tsv](databases/Lexique382/Lexique382.tsv)
 - README: [databases/README-Lexique382](databases/Lexique382/README-Lexique.md) 
 - Website: <http://www.lexique.org>


## Frantext ##

La table _Frantext_ fournit la liste de tous les types orthographiques README-Gougenheimobtenus après tokenization du sous-corpus de Frantext utilisé pour calculer les fréquences "livres"" de Lexique. 

 - Table: [Frantext.tsv](databases/Frantext/Frantext.tsv)
 - README: [README-Frantext](databases/Frantext/README-Frantext.md)


## French Lexicon Project ##

The _French Lexicon Project_ (FLP) provides visual lexical decision time for about 39000 French words, obtained from 1,000 participants from different universities (Each participant read XXX items).

 - Tables:  
      * [FLP.words.csv](databases/FrenchLexiconProject/FLP.words.csv)  
      * [FLP.pseudowords.csv](databases/FrenchLexiconProject/FLP.pseudowords.csv)
 - README: [README-FrenchLexiconProject](databases/FrenchLexiconProject/README-FrenchLexiconProject.md))
 - Website: <https://sites.google.com/site/frenchlexicon/>


## Megalex ##

_Megalex_ provides visual and auditory lexical decision times and accuracy rates several thousands of words: Visual lexical decision data are available for 28466 French words and the same number of pseudowords, and auditory lexical decision data are available for 17876 French words and the same number of pseudowords. 

   - Table: ???
   - README: [README-Megalex](databases/Megalex/README-Megalex.md)
   - Website:

## Chronolex ##

_Chronolex_ provides naming times, lexical decision times and progressive demasking scores on most monosyllabic monomorphemic French (about 1500 items).

Thirty-seven participants (psychology students from Blaise Pascal University in Clermont-Ferrand) were tested in the naming task, 35 additionnal participants in the lexical decision task and 33 additionnal participants (from the same pool) were tested in the progressive demasking task.

   - Table: [Chronolex.tsv](databases/Chronolex/Chronolex.tsv)
   - README: [README-Chronolex](databases/Chronolex/README-Chronolex.md)
   - Website:

## Gougenheim100 ##

La base _Gougenheim100_ présente, pour 1064 mots, leur fréquence et leur répartition (nombre de textes dans lesquels ils apparaissent). Le corpus sur lequel, il est basé est un corpus de langue oral basé sur un ensembles d'entretiens avec 275 personnes. C'est donc non seulement un corpus de langue orale mais aussi de langue produite. Le corpus original comprend 163 textes, 312.135 mots et 7.995 lemmes différents. 

   - Table: [gougenheim.tsv](databases/Gougenheim100/gougenheim.tsv)
   - README: [README-Gougenheim](databases/Gougenheim100/README-Gougenheim.md)


## SUBTLEXus ##

_SUBTLEXus_ provide frequency measures based on American movies subtitles (51 million words in total). There are two measures:

- The frequency per million words, called SUBTLEXWF (Subtitle frequency: word form frequency)
- The percentage of films in which a word occurs, called SUBTLEXCD (Subtitle frequency: contextual diversity; see Adelman, Brown, & Quesada (2006) for the qualities of this measure).

   - Table: [SUBTLEXus74286wordstextversion.tsv](databases/SUBTLEXus/SUBTLEXus74286wordstextversion.tsv)
   - README: [README-SUBTLEXus](databases/SUBTLEXus/README-SUBTLEXus.md)
   - Website: <https://www.ugent.be/pp/experimentele-psychologie/en/research/documents/subtlexus>


March 2019
