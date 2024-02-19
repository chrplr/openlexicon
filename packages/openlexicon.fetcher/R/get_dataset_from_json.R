#' Download (only if needed), the dataset 'filename' indicated from the json description file
#'
#' @param json_url URL to json file.
#' @param local_rds Name of the local rds file.
#'
#' @return The path to the local version of the dataset.
#' @export
#'
#' @examples
#' \dontrun{
#' get_dataset_from_json("http://www.lexique.org/databases/_json/Lexique383.json", "Lexique383.rds")
#' }

get_dataset_from_json <- function (json_url, local_rds) {

    dest_dir <- file.path(get_data.home() )
    dest_rds <- paste0(paste(dest_dir, local_rds, sep = "/"), ".rds")

    # print(dest_rds)

    json_data <- rjson::fromJSON(file = json_url)
    remote_rds <- json_data$url_rds
    remote_md5_rds <- json_data$md5_rds

    # print(!file.exists(dest_rds))
    # print(tools::md5sum(dest_rds))
    # print(remote_md5_rds)
    # print(remote_rds)

    if (!file.exists(dest_rds) || (tools::md5sum(dest_rds) != remote_md5_rds) ) {

        utils::download.file(remote_rds, dest_rds, mode = "wb")

    }

    # if (tools::md5sum(dest_rds) != remote_md5_rds) {
    #
    #     warning (
    #         "Something is wrong: the md5sums don't match. Either the upstream files are inconsistent or someone is messing with your internet connection."
    #         )
    #
    #     return (NULL)
    #
    # }

    return (dest_rds)

}
