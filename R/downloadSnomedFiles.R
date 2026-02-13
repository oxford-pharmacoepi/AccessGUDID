#' Download implantable devices csv list and its corresponding SNOMED code from Access GUDID.
#' Please see:
#' https://accessgudid.nlm.nih.gov/resources/developers/v3/implant_list_download
#' for more information
#'
#' @param api_key Personal api key. Please see for more information:
#' https://accessgudid.nlm.nih.gov/resources/developers/v3/device_snomed_api
#' @param directory Path where to download the ZIP file
#' @param folderName Name of the ZIP folder that will be created
#'
#' @return A zip folder will be created with the implantable devices csv and its
#' correspondent SNOMED code.
#' @export
downloadSnomedFiles <- function(api_key, directory, folderName = "SnomedFilesAccessGUDID"){
  omopgenerics::assertCharacter(directory, length = 1)
  omopgenerics::assertCharacter(api_key, length = 1)
  omopgenerics::assertCharacter(folderName, length = 1)

  # Create directory
  if(dir.exists(paste0(directory,"/", folderName,".zip"))){
    cli::cli_inform(c("i" = "{folderName} in {directory} already exists and will be overwritten."))
    dir.create(paste0(directory,"/", folderName))
  }

  st <- getTicketInternal(api_key)

  # Download SNOMED files
  zip_path <- file.path(paste0(directory, "/", folderName,".zip"))
  res <- httr2::request("https://accessgudid.nlm.nih.gov/api/v3/devices/implantable/download") |>
    httr2::req_url_query(ticket = st) |>
    httr2::req_perform(path =   zip_path)

  invisible(res)
}

getTicketInternal <- function(api_key){
  # Get ticket
  resp_tgt <- httr2::request("https://utslogin.nlm.nih.gov/cas/v1/api-key") |>
    httr2::req_body_form(apikey = api_key) |>
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
