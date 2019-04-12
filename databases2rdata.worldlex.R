#! /usr/bin/env Rscript
# convert the tsv files in `databases` into R dataframes and save them in RData format in the `rdata` folder
# Time-stamp: <2019-04-09 11:29:43 christophe@pallier.org>


require(tidyverse)

worldlexfr <- read_delim('databases/WorldLex/Fre.Freq.3.Hun.txt', delim='\t')
worldlexfr$nbcar = nchar(worldlexfr$Word)
worldlexfr$nbcar <- as.integer(worldlexfr$nbcar)
worldlexfr <- worldlexfr %>%
  select(Word, nbcar, everything())
save(worldlexfr, file='rdata/WorldLex_FR.RData')


worldlexen <- read_delim('databases/WorldLex/Eng_US.Freq.3.Hun.txt', delim='\t')
worldlexen$nbcar = nchar(worldlexen$Word)
worldlexen$nbcar <- as.integer(worldlexen$nbcar)
worldlexen <- worldlexen %>%
  select(Word, nbcar, everything())
save(worldlexen, file='rdata/WorldLex_EN.RData')

