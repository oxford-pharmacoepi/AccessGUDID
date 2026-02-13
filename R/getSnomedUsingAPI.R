#' Get SNOMED code from a Device Identifier via ACCESGUDID
#'
#' @param api_key Personal api key. Please see for more information: https://accessgudid.nlm.nih.gov/resources/developers/v3/device_snomed_api
#' @param device_di Device Identifier
#'
#' @return A table with the SNOMED code, the device brand, the description,
#' the catalog number, and the company name
#' @export

getSomedUsingAPI <- function(api_key, device_di){

  omopgenerics::assertCharacter(api_key, length = 1)
  omopgenerics::assertCharacter(device_di, length = 1)

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

  # Get SNOMED code
  res <- httr2::request("https://accessgudid.nlm.nih.gov/api/v3/devices/snomed") |>
    httr2::req_url_query(ticket = st, di = device_di) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  # Get general information
  tab <- httr2::request("https://accessgudid.nlm.nih.gov/api/v2/devices/lookup.json") |>
    httr2::req_url_query(di = device_di) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  result <- dplyr::tibble(
    "udi" = device_di,
    "device_brand" = tab$gudid$device$brandName,
    "description" = tab$gudid$device$deviceDescription,
    "catalog_number" = tab$gudid$device$catalogNumber,
    "company_name" = tab$gudid$device$companyName,
    "snomed_name"  = res$concepts[[1]]$snomedCTName,
    "snomed_concept_code" = res$concepts[[1]]$snomedIdentifier
  )

  return(result)
}
