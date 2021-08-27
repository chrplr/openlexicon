# Liste de mots français Gutenberg

Le fichier [liste.de.mots.francais.frgut.txtliste-frgtu.txt](liste.de.mots.francais.frgut.txt) contient une liste de 336531 mots du français.

J'ai produit cette liste à partir du dictionnaire [Francais-GUTenberg-1.0](Francais-Gutenberg-reference.pdf) de Christophe Pythoud (Pythoud, C. (1998) Français-GUTenberg : un nouveau dictionnaire français pour ISPELL. problèmes résolus et intégration de contributions extérieures _Cahiers GUTenberg_,  n° 28-29, p. 252-275 ([pdf](http://cahiers.gutenberg.eu.org/cg-bin/article/CG_1998___28-29_252_0.pdf))
). 

Pour cela j'ai appliqué la procédure suivante, sur une machine sur laquelle était installé `ispell` (version 3.2.06):

1.  Installation de Francais-Gutenberg:

        wget http://ftp.free.fr/mirrors/ftp.gentoo.org/distfiles/28/Francais-GUTenberg-v1.0.tar.gz
        tar xzf Francais-GUTenberg-v1.0.tar.gz
        cd Francais-GUTenberg-v1.0
        ./makehash
        sudo cp fr*.{hash,aff} /usr/lib/ispell

2.  Génération de la liste de mots:

        cd dicos
        cat nonverbes.dico series.dico verbes-gp*.dico verbes-varia.dico | ispell -d francais -e |  iconv -f iso8859-1 -t utf-8 > /tmp/liste.txt
        perl -pe 's/ /\n/g' /tmp/liste.txt | grep -v "'" | sort | uniq | awk 'NF>0' > liste.de.mots.francais.frgut.txt




<Christophe@Pallier.org>

<http://www.pallier.org>


[Online access](http://www.lexique.org/shiny/openlexicon) | [Openlexicon](http://chrplr.github.io/openlexicon)
