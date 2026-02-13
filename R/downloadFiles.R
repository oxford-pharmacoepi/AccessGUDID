#' Download implantable devices csv list from Access GUDID. Please see:
#' https://accessgudid.nlm.nih.gov/resources/developers/v3/implant_list_download
#' for more information
#'
#' @param directory Path where to download the ZIP file
#' @param folderName Name of the ZIP folder that will be created
#'
#' @return A zip folder will be created with the implantable devices csv data
#' @export
downloadFiles <- function(directory, folderName = "FilesAccessGUDID"){
  omopgenerics::assertCharacter(directory, length = 1)
  omopgenerics::assertCharacter(folderName, length = 1)

  # Create directory
  if(dir.exists(paste0(directory,"/", folderName,".zip"))){
    cli::cli_inform(c("i" = "{folderName} in {directory} already exists and will be overwritten."))
    dir.create(paste0(directory,"/", folderName))
  }

  # Download SNOMED files
  zip_path <- file.path(paste0(directory, "/", folderName,".zip"))
  res <- httr2::request("https://accessgudid.nlm.nih.gov/api/v3/devices/implantable/download") |>
    httr2::req_url_query() |>
    httr2::req_perform(path = zip_path)

  invisible(res)
}
