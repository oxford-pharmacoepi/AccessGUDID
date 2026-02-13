#' Get SNOMED code from a Device Identifier via an API from ACCESGUDID
#'
#' @param apiKey Personal api key. Please see for more information: https://accessgudid.nlm.nih.gov/resources/developers/v3/device_snomed_api
#' @param deviceDI Device Identifier. Only one DI each time is allowed. If you need to
#' map a long list of DI, please see `getSnomed()`.
#'
#' @return A table with the SNOMED code, the device brand, the description,
#' the catalog number, and the company name
#' @export
getSomedUsingAPI <- function(apiKey, deviceDI){

  omopgenerics::assertCharacter(apiKey, length = 1)
  omopgenerics::assertCharacter(deviceDI, length = 1)

  st <- getTicketInternal(apiKey)

  # Get SNOMED code
  res <- httr2::request("https://accessgudid.nlm.nih.gov/api/v3/devices/snomed") |>
    httr2::req_url_query(ticket = st, di = deviceDI) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  # Get general information
  tab <- httr2::request("https://accessgudid.nlm.nih.gov/api/v2/devices/lookup.json") |>
    httr2::req_url_query(di = deviceDI) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  result <- dplyr::tibble(
    "udi" = deviceDI,
    "device_brand" = tab$gudid$device$brandName,
    "description" = tab$gudid$device$deviceDescription,
    "catalog_number" = tab$gudid$device$catalogNumber,
    "company_name" = tab$gudid$device$companyName,
    "snomed_name"  = res$concepts[[1]]$snomedCTName,
    "snomed_concept_code" = res$concepts[[1]]$snomedIdentifier
  )

  return(result)
}
