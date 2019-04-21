# Introduction aux expressions régulières #

Les expressions régulières --- ou _regex_ --- sont des “patterns” qui permettent de rechercher des mots possédant certaines propriétés. 

*    `ion` : recherche les mots qui contiennent la chaine _ion_, dans n’importe quelle position.
*    `oid|ion|ein` : recherche les mots qui contiennent (au moins) une des trois chaînes“_iod_, _ion_ ou _ein_ (| = ou). Par exemple, vous pouvez rechercher des mots qui _contiennent_ chien, chat ou lapin avec la regex chien|chat|lapin
*    `ion$` : mots se terminant par _ion_ ($=fin de mot)
*    `^anti` : recherche tous les mots commençant par _anti_ (^=début de mot)
*    `^maison$` : recherche le mot _maison_ exactement
*    `^jour$|^nuit$|^matin$|^soir$` : _jour_ ou _nuit_ ou _matin_ ou _soir_ (permet de rechercher une liste de mots)
*    `^p..r$` : mots de quatre lettres commençant par _p_, finisant pas _r_ (`.` = n’importe quel caractère)
*    `^p.*r$` : mots commencant par _p_ et finissant par _r_ (`*`= répétitions – 0 ou plusieurs fois – du caractère précédent, ici ‘`.`’, donc n’importe quel caractère)
*    `[aeiou][aeiou]` : mots contenant 2 voyelles successives (`[]` = classe de caractères)
*    `^[aeiou]` : mots commençant par une voyelle
*    `^[^aeriou]` : mots ne commençant pas par une voyelle

Il existe de nombreux tutoriaux concernant les _regex_ sur le web, notamment <http://regextutorials.com/index.html> et <http://www.canyouseome.com/guide-regex/>

La bible sur le sujet est le livre _Maitriser les expressions régulières_ (voir <)http://regex.info/book.html>)

Une regex décrit un automate de transition à états finis. Le site <https://regexper.com/> vous permet de visualiser l’automate associé à votre regex. Par exemple:

`[ptk].*[aiou][aiou].?ion$` correspond à l’automate fini:

![](fsa.png)

