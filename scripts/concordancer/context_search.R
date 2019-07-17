---
title: "R Notebook"
output: html_notebook
---

# 


From the corpus, we create a dictionnary associating words to lines numbers.

```{r}
source('../set-variables.R')
uscorpuspath <- file.path(DATABASES, 'SUBTLEX-US', 'Subtlex-US-corpus.txt.gz')  # it should be tokenized
uscorpus <- scan(uscorpuspath, what=character(), sep='\n')
```

```{r}
assoc <- new.env()
for (line in 1:length(uscorpus))
{
  for (token in strsplit(uscorpus[line])[[1]])
    if exists(token, assoc) { 
      assign(token, append(token, l), assoc)
    } else {}
     assign(token, l, envdir=assoc)
}
```

