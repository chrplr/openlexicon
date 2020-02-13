# Time-stamp: <2008-10-13 13:55:42 pallier>


hyph2.pallier.tex: the modified version of frhyph.tex
lexique3.txt: the list of French words
Makefile: the target
 

-------------------

You must have a complete tex/latex installation.

You will need to edit the language.dat file (located in
/usr/share/texmf-texlive/tex/generic/config/language.dat
on the texlive distribution in linux/ubuntu) to load your own version
of the hyphenation patterns.
 
After modifying hyph2.pallier.tex, type

make pal.fmt  

This create pal.fmt, a latex fmt file. Then:

make cesure.log

This processes "cesure.tex" (which includes lexique3.txt: the list of
french words) and produces "cesure.log" containing the hyphenized words.









