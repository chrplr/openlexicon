#! /usr/bin/env Rscript
# Time-stamp: <2019-04-25 11:45:30 christophe@pallier.org>


require(tidyverse)

worldlexfr <- read_delim('Fre.Freq.3.Hun.txt', delim='\t')
worldlexfr$nbcar = nchar(worldlexfr$Word)
worldlexfr$nbcar <- as.integer(worldlexfr$nbcar)
worldlexfr <- worldlexfr %>%
  select(Word, nbcar, everything())
save(worldlexfr, file='WorldLex_FR.RData')


worldlexen <- read_delim('Eng_US.Freq.3.Hun.txt', delim='\t')
worldlexen$nbcar = nchar(worldlexen$Word)
worldlexen$nbcar <- as.integer(worldlexen$nbcar)
worldlexen <- worldlexen %>%
  select(Word, nbcar, everything())
save(worldlexen, file='WorldLex_EN.RData')

