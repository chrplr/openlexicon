
<!-- README.md is generated from README.Rmd. Please edit that file -->

# openlexicon.fetcher

<!-- badges: start -->
<!-- badges: end -->

The goal of `openlexicon.fetcher` is to facilitate the downloaf of
lexical databases related to the [openlexicon
project](http://openlexicon.fr).

## Installation

You can install the development version of openlexicon.fetcher from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("chrplr/openlexicon/packages/openlexicon.fetcher")
```

## Example

You can download any list of databases as follows:

``` r
library(openlexicon.fetcher)
fetch_datasets(listofdatasets = c("Lexique3", "Voisins", "Anagrammes") )
```
