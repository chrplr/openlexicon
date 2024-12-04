#' Creating a json file from metadata supplied by the user.
#'
#' @param name Name of the database.
#' @param description Description of the database.
#' @param url_tsv URL for the tsv file.
#' @param url_rds URL for the rds file.
#' @param output_dir Output directory.
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
        url_rds = "http://www.lexique.org/databases/Lexique382/Lexique382.rds",
        output_dir = getwd()
        ) {

    # validating the "name" parameter
    stopifnot(
        "name must contain only characters..." =
            stringr::str_detect(string = name, pattern = "^[[:alnum:].-]+$")
        )

    # validating the output directory
    stopifnot(
        "output_dir must be a valid directory path." = dir.exists(output_dir)
        )

    # putting all info together in a list
    x <- list(name = name, description = description, url_tsv = url_tsv, url_rds = url_rds)

    # converting the list to a formatted JSON string with line breaks
    json_file <- jsonlite::toJSON(x, pretty = TRUE, auto_unbox = TRUE)

    # constructing the full file path
    file_path <- file.path(output_dir, paste0(name, ".json") )

    # writing the .json file in the current directory
    writeLines(json_file, file_path)

    # informing the user of the file creation
    cat("JSON file created at:", file_path, "\n")

}
