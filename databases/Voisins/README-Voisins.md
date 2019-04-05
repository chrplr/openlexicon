# Voisins 1.02 

Le fichier
[voisins.txt](http://www.lexique.org/databases/Voisins/voisins.txt.gz) contient
divers descripteurs concernant les voisins orthographiques (calculés d'après les
130000 entrées de la base `Graphemes` de Lexique262).

Les voisins orthographiques d'un mot sont les mots qui peuvent être
créés en changeant une lettre sans modifier pour autant la position des autres
lettres (Coltheart, Davelaar, Jonasson et Besner, 1977). En d'autres termes,
les voisins sont tous les mots différents d'un autre uniquement par la
substition d'une seule lettre. Ainsi "vol" a commme voisins "vil" ou "bol"

Cette base est constituée des champs suivants:

* Graph: Toutes les entrées orthographiques de Lexique
* NbVoisOrth: Le nombre de voisins orthographiques.
* VoisOrth: Les différents voisins orthographiques.
* FreqVoisOrth: Les différentes fréquences (de Frantext et par millions) de
      chacun des voisins
* FreqCum: La fréquence cumulée de tous les voisins
    
## Auteurs ##

* Boris_New
* Christophe_Pallier qui a conçu l'algorithme

## Licence ##

CC-BY-SA
