# Voisins1 1.00 Grâce à une idée de Christophe Pallier (implémentée par Boris New)
# Utilisé en conjonction avec Voisins2, cela permet de calculer le nombre de voisins d'une liste de mots
# Il prend en entrée UNE SEULE colonne avec une liste de mots
# Ex: cut -f1 PetiteBase.txt | perl voisins1.pl >Resultats1.txt
# ET: perl voisins2.pl Resultats1.txt >Resultats2.txt

while(<>){

	$lettre=0;
	@F=split("");
	chomp;
	print "$_\t";
	#@F=@F;
	for ($i=0;$i<@F-1;$i++){
		for ($j=0;$j<@F-1;$j++){
			if ($j==$lettre){print "_";}
			else {print "$F[$j]";
			if ($j==@F-2){print "\t";}
			}
		
		
	}
	$lettre++;
}
print"\n";
}
