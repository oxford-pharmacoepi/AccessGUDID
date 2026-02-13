#' Download implantable devices csv list from Access GUDID. Please see:
#' https://accessgudid.nlm.nih.gov/download/delimited
#' for more information.
#' @param directory Path where to download the ZIP file
#' @param release Release version to be downloaded
#'
#' @return A folder with the release name will be created with the implantable devices data in txt format
#' @export
downloadFiles <- function(directory, release = "AccessGUDID_Delimited_Full_Release_20260202"){
  omopgenerics::assertCharacter(directory, length = 1)

  if( dir.exists(paste0(directory,"/", release)) ){
    cli::cli_inform(c("i" = "{release} in {directory} already exists and will be overwritten."))
  }

  zip_path <- file.path(directory, paste0(release, ".zip"))
  url <- paste0("https://accessgudid.nlm.nih.gov/release_files/download/", release, ".zip")

  cli::cli_inform(message = c("i" = "Downloading {release} from ACCESSGUDID"))
  if (!interactive()) {
    res <- httr2::request(url) |>
      httr2::req_perform(path = zip_path)
  } else {
    addProgressBar()
    res <- httr2::request(url) |>
      httr2::req_progress() |>
      httr2::req_perform(path = zip_path)
  }

  cli::cli_inform(message = c("i" = "Unzipping {release}.zip. This may take a while..."))
  unzip(zip_path, exdir = release)

  cli::cli_inform(message = c("v" = "Unzipping completed. The previous .zip file will be removed."))
  unlink(zip_path)

  return(gsub(".zip","", zip_path))
}
