#' Load in memory the rds files listed in list_rds, in variables with the names matching names(list_rds).
#'
#' @param tsv_url URL to the original tsv file.
#' @param table_name Name of the output rds file (without extension).
#'
#' @return Returns a rds file.
#' @export
#'
#' @examples
#' \dontrun{
#' tsv_to_rds(tsv_url)
#' }

tsv_to_rds <- function (tsv_url, table_name) {

    tsv_file <- readr::read_delim(file = tsv_url, delim = "\t")
    saveRDS(object = tsv_file, file = paste0(table_name, ".rds") )

}
