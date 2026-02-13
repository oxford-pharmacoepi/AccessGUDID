#' Download implantable devices csv list and its corresponding SNOMED code from Access GUDID.
#' Please see:
#' https://accessgudid.nlm.nih.gov/resources/developers/v3/implant_list_download
#' for more information
#'
#' @param apiKey Personal api key. Please see for more information:
#' https://accessgudid.nlm.nih.gov/resources/developers/v3/device_snomed_api
#' @param directory Path where to download the ZIP file
#' @param release Release version
#'
#' @return A folder with the name "implantable_data" will be created with the implantable devices csv and its
#' correspondent SNOMED code.
#' @export
downloadSnomedFiles <- function(apiKey, directory, release = "v3"){
  omopgenerics::assertCharacter(directory, length = 1)
  omopgenerics::assertCharacter(apiKey, length = 1)
  omopgenerics::assertCharacter(release, length = 1)

  # Create directory
  folderName <- "implantable_list"

  if( dir.exists(paste0(directory,"/", folderName)) ){
    cli::cli_inform(c("i" = "{folderName} in {directory} already exists and will be overwritten."))
  }

  cli::cli_inform(message = c("i" = "Getting single use ticket"))
  st <- getTicketInternal(apiKey)

  # Download SNOMED files
  cli::cli_inform(message = c("i" = "Downloading implantable_list from ACCESSGUDID"))
  zip_path <- file.path(paste0(directory, "/", folderName,".zip"))
  url <- paste0("https://accessgudid.nlm.nih.gov/api/", release,"/devices/implantable/download")

  if (!interactive()) {
    res <- httr2::request(url) |>
      httr2::req_url_query(ticket = st) |>
      httr2::req_perform(path = zip_path)
  } else {
    addProgressBar()

    res <- httr2::request(url) |>
      httr2::req_url_query(ticket = st) |>
      httr2::req_progress() |>
      httr2::req_perform(path = zip_path)
  }

  cli::cli_inform(message = c("i" = "Unzipping {folderName}. This may take a while..."))
  unzip(zip_path, exdir = folderName)

  cli::cli_inform(message = c("v" = "Unzipping completed. The previous .zip file will be removed."))
  unlink(zip_path)
}

addProgressBar <- function(){
  old <- getOption("cli.progress_show_after")
  options(cli.progress_show_after = 0)
  on.exit(options(cli.progress_show_after = old), add = TRUE)
}
getTicketInternal <- function(apiKey){
  # Get ticket
  resp_tgt <- httr2::request("https://utslogin.nlm.nih.gov/cas/v1/api-key") |>
    httr2::req_body_form(apikey = apiKey) |>
    httr2::req_perform()

  doc <- resp_tgt |>
    httr2::resp_body_string() |>
    xml2::read_html()

  form_node <- xml2::xml_find_first(doc, ".//form")
  action_url <- xml2::xml_attr(form_node, "action")

  tgt <- sub(".*/(TGT-[A-Za-z0-9-]+)$", "\\1", action_url)
  service_url <- "http://umlsks.nlm.nih.gov"

  st_res <- httr2::request(paste0("https://utslogin.nlm.nih.gov/cas/v1/tickets/", tgt)) |>
    httr2::req_body_form(service = service_url) |>
    httr2::req_perform()

  st <- st_res |>
    httr2::resp_body_string() |>
    trimws()

  return(st)
}
