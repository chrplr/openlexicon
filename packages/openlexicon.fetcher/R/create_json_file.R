#' Creating json file from metadata supplied by the user.
#'
#' @param name Name of the database.
#' @param description Description of the database.
#' @param url_tsv URL for the tsv file.
#' @param url_rds URL for the rds file.
#'
#' @return A json file.
#' @export
#'
#' @examples
#' # creating the json file
#' \dontrun{
#' create_json_file(
#'     name = "lexique3",
#'     description = "Lexique382 is a French lexical database.",
#'     url_tsv = "http://www.lexique.org/databases/Lexique382/Lexique382.tsv",
#'     url_rds = "http://www.lexique.org/databases/Lexique382/Lexique382.rds"
#'     )
#' }

create_json_file <- function (
        name = "lexique3",
        description = "Lexique382 is a French lexical database.",
        url_tsv = "http://www.lexique.org/databases/Lexique382/Lexique382.tsv",
        url_rds = "http://www.lexique.org/databases/Lexique382/Lexique382.rds"
        ) {

    stopifnot(
        "name must contain only characters..." =
            stringr::str_detect(string = name, pattern = "^[[:alnum:].-]+$")
        )

    x <- list(name = name, description = description, url_tsv = url_tsv, url_rds = url_rds)
    json_file <- rjson::toJSON(x = x, indent = 4, method = "C")

    write(rjson::toJSON(x), paste0(name, ".json") )

}
