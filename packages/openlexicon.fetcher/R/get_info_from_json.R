#' Extract information fields from a json file
#'
#' @param json_url URL to json file.
#'
#' @return A list of information.
#' @export
#'
#' @examples
#' get_info_from_json(json_url = "http://www.lexique.org/databases/_json/anagrammes.json")

get_info_from_json <- function (json_url) {

    json_data <- rjson::fromJSON(file = json_url)

    return (
        list(
            description = json_data$description,
            readme = json_data$readme,
            website = json_data$website,
            language = json_data$tags[1],
            id_lang = json_data$id_lang,
            mandatory_columns = json_data$mandatory_columns,
            column_names = json_data$column_names
            )
        )

}
