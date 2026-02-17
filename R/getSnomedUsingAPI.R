#' Get SNOMED code from a Device Identifier via an API from ACCESGUDID
#'
#' @param apiKey Personal api key. Please see for more information: https://accessgudid.nlm.nih.gov/resources/developers/v3/device_snomed_api
#' @param deviceDI Device Identifier. Only one DI each time is allowed. If you need to
#' map a long list of DI, please see `getSnomed()`.
#'
#' @return A table with the SNOMED code, the device brand, the description,
#' the catalog number, and the company name
#' @export
getSnomedUsingAPI <- function(apiKey, deviceDI){

  omopgenerics::assertCharacter(apiKey, length = 1)
  omopgenerics::assertCharacter(deviceDI, length = 1)

  st <- getTicketInternal(apiKey)

  # Get SNOMED code
  res <- httr2::request("https://accessgudid.nlm.nih.gov/api/v3/devices/snomed") |>
    httr2::req_url_query(ticket = st, di = deviceDI) |>
    httr2::req_error(is_error = ~FALSE) |>
    httr2::req_perform()

  if (httr2::resp_status(res) >= 400) {
    cli::cli_warn("No connexion was established. This might mean that there is no SNOMED concept available for this DI. Returning a table with snomed_concept_code = 0.")
    res <- list("concepts" = list("1" = dplyr::tibble(
      "snomedIdentifier" = "0",
      "snomedCTName"  = "No matching concept")))

  } else {
    res <- res |>
      httr2::resp_body_json()
  }

  # Get general information
  tab <- httr2::request("https://accessgudid.nlm.nih.gov/api/v2/devices/lookup.json") |>
    httr2::req_url_query(di = deviceDI) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  result <- dplyr::tibble(
    "device_di" = deviceDI,
    "brand_name" = tab$gudid$device$brandName,
    "device_description" = tab$gudid$device$deviceDescription,
    "company_name" = tab$gudid$device$companyName,
    "catalogue_number" = tab$gudid$device$catalogNumber,
    "snomed_concept_code" = res$concepts[[1]]$snomedIdentifier,
    "snomed_name"  = res$concepts[[1]]$snomedCTName
  )

  return(result)
}
