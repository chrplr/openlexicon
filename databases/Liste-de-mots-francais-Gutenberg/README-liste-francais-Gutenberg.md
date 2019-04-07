# Liste de mots français Gutenberg

Le fichier [liste.de.mots.francais.frgut.txtliste-frgtu.txt](liste.de.mots.francais.frgut.txt) contient une liste de 336531 mots du français.

J'ai produit cette liste à partir du dictionnaire [Francais-GUTenberg-1.0](Francais-Gutenberg-reference.pdf) de Christophe Pythoud (Pythoud, C. (1998) Français-GUTenberg : un nouveau dictionnaire français pour ISPELL. problèmes résolus et intégration de contributions extérieures _Cahiers GUTenberg_,  n° 28-29, p. 252-275 ([pdf](http://cahiers.gutenberg.eu.org/cg-bin/article/CG_1998___28-29_252_0.pdf))
). 

Pour cela j'ai appliqué la procédure suivante, sur une machine sur laquelle était installé ispell version 3.2.06:

1.  Installation de Francais-Gutenberg:

        wget http://www.unil.ch/ling/cp/Francais-GUTenberg-v1.0.tar.gz
        tar xzf Francais-GUTenberg-v1.0.tar.gz
        cd Francais-GUTenberg-v1.0
        makehash
        sudo cp fr*.{hash,aff} /usr/lib/ispell

2.  Génération de la liste de mots:

        cd dicos
        cat nonverbes.dico series.dico verbes-gp*.dico verbes-varia.dico | ispell -d francais -e >~/liste1.txt
        perl -pe 's/ /\n/g' ~/liste1.txt | grep -v "'" | sort | uniq | awk 'NF>0' >~/liste.de.mots.francais.frgut.txt




<Christophe@Pallier.org>

<http://www.pallier.org>

