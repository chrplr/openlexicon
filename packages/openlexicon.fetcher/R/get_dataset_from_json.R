#' Downloading (only if needed) the dataset 'filename' indicated from the json description file
#'
#' @param json_url URL to json file.
#' @param local_rds_name Name of the local rds file.
#'
#' @return The path to the local version of the dataset.
#' @export
#'
#' @examples
#' \dontrun{
#' get_dataset_from_json(
#'     json_url = "http://www.lexique.org/databases/_json/Lexique383.json",
#'     local_rds_name = "Lexique383"
#'     )
#' }

get_dataset_from_json <- function (json_url, local_rds_name) {

    # defining the output directory and filename
    dest_dir <- file.path(get_data.home() )
    dest_rds <- paste0(paste(dest_dir, local_rds_name, sep = "/"), ".rds")

    # downloading the content of the json file
    # json_data <- rjson::fromJSON(file = json_url)
    # json_url <- "http://www.lexique.org/databases/links/AoA-32lang.json"
    # json_url = "http://www.lexique.org/databases/_json/Lexique383.json"
    json_data <- jsonlite::fromJSON(txt = json_url)

    # retrieving the url for the rds file
    remote_rds <- json_data$url_rds

    # retrieving the md5sum for the rds file
    remote_md5_rds <- json_data$md5sum

    # if the md5sum does not exist or has changed, downloading the rds file
    if (!file.exists(dest_rds) || (tools::md5sum(dest_rds) != remote_md5_rds) ) {

        utils::download.file(remote_rds, dest_rds, mode = "wb")

    }

    # checking the md5sum for the rds file
    if (tools::md5sum(dest_rds) != remote_md5_rds) {

        warning (
            "Something is wrong: the md5sums don't match. Either the upstream files are inconsistent or someone is messing with your internet connection."
            )

        return (NULL)

    }

    # returning the rds file
    return (dest_rds)

}
