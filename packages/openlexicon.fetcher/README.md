
<!-- README.md is generated from README.Rmd. Please edit that file -->

# openlexicon.fetcher

<!-- badges: start -->

<!-- badges: end -->

The goal of `openlexicon.fetcher` is to facilitate the download of
lexical databases related to the [openlexicon
project](http://openlexicon.fr).

## Installation

You can install the development version of `openlexicon.fetcher` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("chrplr/openlexicon/packages/openlexicon.fetcher")
```

## Usage

### Downloading datasets

You can load (or download if needed) any list of datasets as follows:

``` r
library(openlexicon.fetcher)
fetch_datasets(datasets = c("Lexique3", "Voisins", "Anagrammes") )
```

Or download all datasets using:

``` r
# getting a list of all available datasets
available_datasets()

# downloading them all
get_all_datasets()
```

Note that, by default, datasets are saved in your home directory in
`~/openlexicon_datasets/`.

### Contributing datasets

To contribute datasets, you can use the `create_json_file()` function to
generate a minimal .json file containing (at least) a name, a concise
description, and an url to download the .rds file containing the data
(see also the `tsv_to_rds()` function to convert .tsv files to .rds if
needed).

``` r
create_json_file(
    name = "lexique3",
    description = "Lexique382 is a French lexical database.",
    url_rds = "http://www.lexique.org/databases/Lexique382/Lexique382.rds"
    )
```
