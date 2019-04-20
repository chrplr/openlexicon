# S'utilise en conjonction avec voisins1.pl
# Ouvrir voisins1.pl pour avoir plus d'explications

open(UN,"<$ARGV[0]");
while(<UN>){

	$lettre=0;
	chomp;
	@F=split("\t");
	#@F=@F;
	# $vois{_baissant} = 1
	# $vois{a_aissant} = 1 
	for ($i=1;$i<@F;$i++){
		$vois{$F[$i]}++;
		# si on ne veut pas voir les voisins (car ça prend plus de mémoire), commenter la ligne suivante
		# $vois{a_aissant} = abaissant 
		$voirvois{$F[$i]} .= "$F[0], " 
		}
}
close(UN);

open(DEUX,"<$ARGV[0]");
while(<DEUX>){
	chomp;
	@F=split("\t");
	for ($i=1;$i<@F;$i++){
	#if($vois{$F[$i]}==1){$vois{$F[$i]}=0;}
	#$vois{$F[$i]}--;
	# $somvois{abaissant} += $vois{_baissant} 
	# $somvois{abaissant} += $vois{a_aissant} 
	$somvois{$F[0]} += $vois{$F[$i]};
	# si on ne veut pas voir les voisins (car ça prend plus de mémoire), commenter la ligne suivante
	$voirvois2{$F[0]} .= $voirvois{$F[$i]};
}
}
close(DEUX);



foreach $i (keys %somvois){
	$som=$somvois{$i}-(length($i));
	# si on ne veut pas voir les voisins (car ça prend plus de mémoire), commenter la ligne suivante
	$voirvois2{$i} =~ s/$i, //g;
	print "$i\t$som";
	# si on ne veut pas voir les voisins (car ça prend plus de mémoire), commenter la ligne suivante
	print "\t$voirvois2{$i}";
	print "\n";
	
}	


#print $vois{"dan_e"};
#print $vois{"arb_e"};
