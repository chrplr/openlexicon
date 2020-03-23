cesure.log: cesure.tex pal.fmt
	tex '&pal' cesure

pal.fmt: hyph2.pallier.tex
	tex -ini -mltex latex.ltx; mv -f latex.fmt pal.fmt

