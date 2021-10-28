#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:45:30 christophe@pallier.org>


require(tidyverse)

makeRDS <- function(filename, outfilename){
  worldlex <- read_delim(filename, delim='\t')
  worldlex$nbcar = nchar(worldlex$Word)
  worldlex$nbcar <- as.integer(worldlex$nbcar)
  worldlex <- worldlex %>%
    select(Word, nbcar, everything())
  saveRDS(worldlex, file=outfilename)
}

makeRDS('Fre.Freq.3.Hun.txt.gz', 'WorldLex_FR.rds')
makeRDS('Eng_US.Freq.3.Hun.txt.gz', 'WorldLex_EN.rds')
makeRDS('Af.Freq.3.Hun.txt.gz', 'WorldLex-Afrikaans.rds')
makeRDS('Alb.Freq.3.Hun.txt.gz', 'WorldLex-Albanian.rds')
makeRDS('Amh.Freq.2.txt.gz', 'WorldLex-Amharic.rds')
makeRDS('Ara.Freq.3.Hun.txt.gz', 'WorldLex-Arabic.rds')
makeRDS('Arm.Freq.3.txt', 'WorldLex-Armenian.rds')
makeRDS('Aze.Freq.3.txt.gz', 'WorldLex-Azeri.rds')
makeRDS('Ben.Freq.3.Hun.txt.gz', 'WorldLex-Bengali.rds')
makeRDS('Bos.Freq.2.txt.gz', 'WorldLex-Bosnian.rds')
makeRDS('Cat.Freq.3.Hun.txt.gz', 'WorldLex-Catalan.rds')
makeRDS('Chi.Freq.2.txt.gz', 'WorldLex-Chinese-Simplified.rds')
makeRDS('Cro.Freq.3.Hun.txt.gz', 'WorldLex-Croatian.rds')
makeRDS('Cy.Freq.3.Hun.txt.gz', 'WorldLex-Welsh.rds')
makeRDS('Cze.Freq.3.Hun.txt.gz', 'WorldLex-Czech.rds')
makeRDS('De.Freq.3.Hun.txt.gz', 'WorldLex-German.rds')
makeRDS('DK.Freq.3.Hun.txt.gz', 'WorldLex-Danish.rds')
makeRDS('Es.Freq.3.Hun.txt.gz', 'WorldLex-Spanish-Spain.rds')
makeRDS('Es_SA.Freq.3.Hun.txt.gz', 'WorldLex-Spanish-South-America.rds')
makeRDS('Est.Freq.3.Hun.txt.gz', 'WorldLex-Estonian.rds')
makeRDS('Fi.Freq.3.txt.gz', 'WorldLex-Finnish.rds')
makeRDS('Ge.Freq.2.txt.gz', 'WorldLex-Georgian.rds')
makeRDS('Gl.Freq.2.txt.gz', 'WorldLex-Greenlandic.rds')
makeRDS('Gre.Freq.3.Hun.txt.gz', 'WorldLex-Greek.rds')
makeRDS('Gu.Freq.3.Hun.txt.gz', 'WorldLex-Gujarati.rds')
makeRDS('He.Freq.3.Hun.txt.gz', 'WorldLex-Hebrew.rds')
makeRDS('Hi.Freq.3.Hun.txt.gz', 'WorldLex-Hindi.rds')
makeRDS('Hu.Freq.3.Hun.txt.gz', 'WorldLex-Hungarian.rds')
makeRDS('Ice.Freq.3.Hun.txt.gz', 'WorldLex-Icelandic.rds')
makeRDS('Id.Freq.3.Hun.txt.gz', 'WorldLex-Indonesian.rds')
makeRDS('Ita.Freq.3.Hun.txt.gz', 'WorldLex-Italian.rds')
makeRDS('Jap.Freq.2.txt.gz', 'WorldLex-Japanese.rds')
makeRDS('Khm.Freq.2.txt.gz', 'WorldLex-Khmer.rds')
makeRDS('Kn.Freq.2.txt.gz', 'WorldLex-Kannada.rds')
makeRDS('Kr.Freq.2.txt.gz', 'WorldLex-Korean.rds')
makeRDS('Kz.Freq.3.Hun.txt.gz', 'WorldLex-Kazakh.rds')
makeRDS('Lit.Freq.3.Hun.txt.gz', 'WorldLex-Lithuanian.rds')
makeRDS('Lv.Freq.3.Hun.txt.gz', 'WorldLex-Latvian.rds')
makeRDS('Mk.Freq.3.txt.gz', 'WorldLex-Macedonian.rds')
makeRDS('Ml.Freq.3.txt.gz', 'WorldLex-Malayalam.rds')
makeRDS('Mn.Freq.3.txt.gz', 'WorldLex-Mongolian.rds')
makeRDS('My.Freq.2.txt.gz', 'WorldLex-Malaysian.rds')
makeRDS('Nep.Freq.3.Hun.txt.gz', 'WorldLex-Nepali.rds')
makeRDS('Nl.Freq.3.Hun.txt.gz', 'WorldLex-Dutch.rds')
makeRDS('Nob.Freq.3.Hun.txt.gz', 'WorldLex-Norwegian.rds')
makeRDS('Pan.Freq.3.txt.gz', 'WorldLex-Punjabi.rds')
makeRDS('Per.Freq.3.txt.gz', 'WorldLex-Persian.rds')
makeRDS('Pl.Freq.3.Hun.txt.gz', 'WorldLex-Polish.rds')
makeRDS('Por_Br.Freq.3.Hun.txt.gz', 'WorldLex-Portuguese-Brazil.rds')
makeRDS('PorEU.Freq.3.Hun.txt.gz', 'WorldLex-Portuguese-Europe.rds')
makeRDS('Ro.Freq.3.Hun.txt.gz', 'WorldLex-Romanian.rds')
makeRDS('Ru.Freq.3.Hun.txt.gz', 'WorldLex-Russian.rds')
makeRDS('Ser.Freq.3.Hun.txt.gz', 'WorldLex-Serbian.rds')
makeRDS('Sin.Freq.3.Hun.txt.gz', 'WorldLex-Sinhala.rds')
makeRDS('Sk.Freq.3.Hun.txt.gz', 'WorldLex-Slovak.rds')
makeRDS('Sl.Freq.3.Hun.txt.gz', 'WorldLex-Slovenian.rds')
makeRDS('Swa.Freq.3.Hun.txt.gz', 'WorldLex-Swahili.rds')
makeRDS('Swe.Freq.3.Hun.txt.gz', 'WorldLex-Swedish.rds')
makeRDS('Ta.Freq.2.txt.gz', 'WorldLex-Tamil.rds')
makeRDS('Tel.Freq.3.Hun.txt.gz', 'WorldLex-Telugu.rds')
makeRDS('Tgl.Freq.2.txt.gz', 'WorldLex-Tagalog.rds')
makeRDS('Tur.Freq.3.Hun.txt.gz', 'WorldLex-Turkish.rds')
makeRDS('Uk.Freq.3.Hun.txt.gz', 'WorldLex-Ukrainian.rds')
makeRDS('Urd.Freq.2.txt.gz', 'WorldLex-Urdu.rds')
makeRDS('Uz_Latin.Freq.2.txt.gz', 'WorldLex-Uzbek.rds')
makeRDS('Vie.Freq.3.Hun.txt.gz', 'WorldLex-Vietnamese.rds')









