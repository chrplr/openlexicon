# Syllabation de Brulex et Lexique

% Time-stamp: <2019-04-09 13:46:49 christophe@pallier.org>

Ce répertoire contient le script qui a servi à  syllabifier les représentations phonologiques de Brulex et de Lexique.

Voici quelques exemples:

| item       | phon    | phonsyll  | nbsyll | skel      |
|------------|---------|-----------|--------|-----------|
| abeille    | abEj    | a-bEj     | 2      | V-CVY     |
| adroit     | adRwa   | a-dRwa    | 2      | V-CCYV    |
| arbre      | aRbR    | aRbR      | 1      | VCCC      |
| astre      | astR    | astR      | 1      | VCCC      |
| bouilloire | bujwaR  | buj-waR   | 2      | CVY-YVC   |
| cadeau     | kadO    | ka-dO     | 2      | CV-CV     |
| castor     | kastOR  | kas-tOR   | 2      | CVC-CVC   |
| chien      | Sj5     | Sj5       | 1      | CYV       |
| costume    | kOstym  | kOs-tym   | 2      | CVC-CVC   |
| exploit    | Eksplwa | Ek-splwa  | 2      | VC-CCCYV  |
| fluide     | fl8id   | fl8id     | 1      | CCYVC     |
| galerie    | galRi   | gal-Ri    | 2      | CVC-CV    |
| joueur     | Zw9R    | Zw9R      | 1      | CYVC      |
| madeleine  | madlEn  | mad-lEn   | 2      | CVC-CVC   |
| notre      | nOtR    | nOtR      | 1      | CVCC      |
| nuage      | n8aZ    | n8aZ      | 1      | CYVC      |
| obstruer   | OpstRye | Op-stRy-e | 3      | VC-CCCV-V |
| polluer    | pOl8e   | pO-l8e    | 2      | CV-CYV    |
| poète      | pOEt    | pO-Et     | 2      | CV-VC     |
| sauterelle | sOtREl  | sO-tREl   | 2      | CV-CCVC   |
| sciure     | sjyR    | sjyR      | 1      | CYVC      |
| skieur     | skj9R   | skj9R     | 1      | CCYVC     |
| sonnerie   | sOnRi   | sOn-Ri    | 2      | CVC-CV    |
| stagner    | stagne  | stag-ne   | 2      | CCVC-CV   |
| tatouer    | tatwe   | ta-twe    | 2      | CV-CYV    |
| tueuse     | t82z    | t82z      | 1      | CYVC      |
| vieillerie | vjEjRi  | vjEj-Ri   | 2      | CYVY-CV   |



Une description (sommaire) des règles de syllabation est disponible dans le document [syllabation.pdf](syllabation.pdf)([^1])

Le programme de syllabation est écrit en langage AWK particulièrement bien adapté pour cette tâche --- Voir mon document "[Utilisation de AWK pour faire des recherches dans Lexique](awk_for_lex.pdf)" et la page de [AWK sur Wikipedia](https://en.wikipedia.org/wiki/AWK#Versions_and_implementations)). 


Fichiers:

* [syllabation.awk](syllabation.awk):  script proprement dit
* [Makefile](Makefile):         sur un système disposant de 'make', genere

* [mots_test.txt](mots_test.txt)  :  liste de mots dont on veut verifier les syllabations
* [tests.txt](tests.txt)      :  resultats de la syllabation (selon brulex, puis selon lexique)


Si [Make](https://opensource.com/article/18/8/what-how-makefile) est installé sur votre machine, il vous suffit de taper:

    make
    make test


Sinon, pour syllaber `brulex.txt`:

    gawk -vphons=2 -vcode=brulex -f syllabation.awk brulex.txt 

et pour syllaber `lexique260_graph.txt`:

    gawk -vphons=2 -f syllabation.awk lexique260_graph.txt 
 

---

[^1]: Pour le choix de la syllabation, voir ma thèse (Christophe Pallier (1994). _Rôle de la syllabe dans la perception de la parole: études attentionnelles_. PhD thesis, École des hautes études en sciences sociales [pdf](http://www.pallier.org/papers/Pallier_phdthesis.pdf))
