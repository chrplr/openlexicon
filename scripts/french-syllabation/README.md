# Syllabation de Brulex et Lexique

% Time-stamp: <2019-04-06 14:16:44 christophe@pallier.org>

Ce répertoire contient le script qui a servi à  syllabifier les représentations phonologiques de Brulex et de Lexique.

Une description (sommaire) des règles de syllabation est disponible dans le document [syllabation.pdf](syllabation.pdf) [^1]

Le programme de syllabation est écrit en langage AWK particulièrement bien adapté pour cette tâche (Pour plus d'informations sur le langage AWK, consultez [AWK on Wikipedia](https://en.wikipedia.org/wiki/AWK#Versions_and_implementations)). 

Pour ceux intéressés, j'ai rédigé un court document intitulé "[Utilisation de AWK pour faire des recherches dans Lexique](awk_for_lex.pdf)".


Fichiers:

* [syllabation.awk](syllabation.awk):  script proprement dit
* [Makefile](Makefile):         sur un système disposant de 'make', genere

* [mots_test.txt](mots_test.txt)  :  liste de mots dont on veut verifier les syllabations
* [tests.txt](tests.txt)      :  resultats de la syllabation (selon brulex, puis selon lexique)


Si [Make](https://opensource.com/article/18/8/what-how-makefile) est installé sur votre machine, il vous suffit de taper:

    make
    make test


Sinon, pour syllaber brulex.txt:

    gawk -vphons=2 -vcode=brulex -f syllabation.awk brulex.txt 

et pour syllaber lexique260_graph.txt:

	gawk -vphons=2 -f syllabation.awk lexique260_graph.txt 
 

---

[^1]: Pour le choix de la syllabation, voir ma thèse (Christophe Pallier (1994). _Rôle de la syllabe dans la perception de la parole: études attentionnelles_. PhD thesis, École des hautes études en sciences sociales [pdf](http://www.pallier.org/papers/Pallier_phdthesis.pdf))
