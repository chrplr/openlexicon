# Permet d'obtenir toutes les fréquences des voisins ainsi que leur fréquence cumulée
# Ce script prend en entrée la sortie de voisins2.pl
# Ce fichier a besoin d'un fichier nommé freqmots.txt ayant deux colonnes: le mot et sa fréquence
# Ex: cut -f1,8 Graphemes.txt >freqmots.txt

# si vous avez fait: perl voisins2.pl Resultats1.txt >Resultats2.txt
# vous pouvez alors faire : perl voisinsfreq.pl Resultats2.txt >Resultats3.txt

open(FREQ,"<freqmots.txt");
while(<FREQ>){
	chomp;
	@F=split("\t");
	$freq{$F[0]}=$F[1];
}

open(UN,"<$ARGV[0]");
while(<UN>){
	chomp;
	@F=split("\t");
	@G=split(", ",$F[2]);
	
	foreach $i (@G){
	$som{$F[0]} += $freq{$i};
	$freqvois{$F[0]} .= "$freq{$i}, ";
	}
	print "$F[0]\t$F[1]\t$F[2]\t$freqvois{$F[0]}\t$som{$F[0]}\n";
}
