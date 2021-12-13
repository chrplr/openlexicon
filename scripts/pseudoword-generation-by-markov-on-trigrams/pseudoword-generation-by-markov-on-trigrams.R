#! /usr/bin/env Rscript
# Time-stamp: <2021-12-13 14:04:09 christophe@pallier.org>

require(stringi)

generate_pseudowords <- function (n, len, models, exclude=NULL)
# generate pseudowords by chaining trigrams.
# n: number of pseudowords to return
# len: length (nchar) of the pseudowords
# models: list of items to get trigrams from
# exclude: list of items to exclude
{
    models <- paste(" ", models, " ", sep="")
    trigs = list()  #  storing the list of trigrams by starting position
    for (cpos in 1:(len - 1))
        trigs[[cpos]] <- stri_encode(substring(models, cpos, cpos + 2), "", "UTF-8")

    pseudos <- character(n)  # will contain the generated pseudowords

    np = 1
    while (np <= n) {
        # Tire au hasard un trigramme en position initiale
        item <- sample(trigs[[1]], 1)

        # Build the item letter by letter by adding compatible trigrams
        for(pos in 2:(len - 1)) {
            # get the last 2 letters of the current item
            lastbigram <- substr(item, pos, pos + 1)

            # Select trigrams staring in position 'pos' and which are compatibles with 'lastbigram'
            compat <- trigs[[pos]][grep(paste(sep="" , "^", lastbigram), trigs[[pos]])]
            if (length(compat) == 0) break  # must start again

            item <- paste(item, substr(sample(compat, 1), 3, 3), sep="")  # add the last letter of the trigram
        }

        # keep item only if not in the 'exclude' list
        if (! is.element(item, exclude) && ! is.element(item, pseudos) && ! is.element(item, models)) {
            pseudos[np] = item
            np = np + 1
        }
    }
    return (substring(pseudos, 2))
}


words <- scan('liste.de.mots.francais.frgut.txt', what=character(), fileEncoding="UTF-8", encoding='UTF-8')
words <- stri_encode(words, "", "UTF-8")
# models <- words[nchar(words, type='width') == 7]
models = words[nchar(words, type='width') > 5]
generate_pseudowords(10, 7, models)
