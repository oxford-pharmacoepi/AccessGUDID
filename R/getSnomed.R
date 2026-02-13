#' Get SNOMED code from a Device Identifier via download files from ACCESGUDID
#'
#' @param snomedFilesDirectory Directory of the zip folder containing the SNOMED ACCESS GUDID files information.
#' Please refer to function `downloadSnomedFiles()` if you have not download the
#' files yet.
#' @param filesDirectory Directory of the zip folder containing the ACCESS GUDID files information.
#' Please refer to function `downloadFiles()` if you have not download the
#' files yet.
#' @param deviceDI Device Identifiers to be searched for
#'
#' @return A table with the SNOMED code, the device brand, the description,
#' the catalog number, and the company name
#' @export
getSnomed <- function(snomedFilesDirectory, filesDirectory, deviceDI){

  omopgenerics::assertCharacter(snomedFilesDirectory, length = 1)
  omopgenerics::assertCharacter(filesDirectory, length = 1)
  omopgenerics::assertCharacter(deviceDI)

  device_di <- dplyr::tibble("device_di" = deviceDI)

  if(!file.exists(snomedFilesDirectory)){
    cli::cli_abort(message = "{snomedFilesDirectory} does not exist. Please ensure it directs
                   to the folder where the files are (i.e., 'home/AccessGUDID_Project/implantable_list')")
  }
  if(!file.exists(filesDirectory)){
    cli::cli_abort(message = "{filesDirectory} does not exist. Please ensure it directs
                   to the folder where the files are (i.e., 'home/AccessGUDID_Project/AccessGUDID_Delimited_Full_Release_20260202')")
  }

  # Read snomed csv files
  snomed_csv <- list.files(snomedFilesDirectory, pattern = ".csv", full.names = TRUE)
  snomed_tab <- readr::read_delim(snomed_csv, progress = TRUE, delim = "|") |>
    dplyr::select("device_di" = "DEVICE_ID",
                  "brand_name" = "BRAND_NAME",
                  "company_name" = "COMPANY_NAME",
                  "snomed" = "SNOMED") |>
    dplyr::mutate("snomed_code" = gsub("\\|.*","",.data$snomed))  |>
    dplyr::mutate("snomed_name" = gsub(".*\\|","",.data$snomed)) |>
    dplyr::select(-"snomed")

  # Read ACCESSGUDID file
  cli::cli_inform(message = c("i" = "Extracting device data"))
  files_txt <- list.files(filesDirectory, pattern = "device.txt", full.names = TRUE)
  device_tab <- readr::read_delim(files_txt, progress = TRUE, delim = "|") |>
    dplyr::select("device_di" = "PrimaryDI",
                  "catalogue_number" = "catalogNumber",
                  "device_description" = "deviceDescription")

  result <- device_di |>
    dplyr::left_join(
      snomed_tab, by = "device_di"
    ) |>
    dplyr::left_join(
      device_tab, by = "device_di"
    ) |>
    dplyr::select("device_di", "brand_name", "device_description", "company_name", "catalogue_number", "snomed_code", "snomed_name") |>
    dplyr::mutate(dplyr::across(c("brand_name", "company_name", "catalogue_number"), ~dplyr::coalesce(., "-"))) |>
    dplyr::mutate("snomed_code" = dplyr::coalesce(.data$snomed_code, "0")) |>
    dplyr::mutate("snomed_name" = dplyr::coalesce(.data$snomed_name, "No matching concept")) |>
    dplyr::mutate("device_description" = dplyr::coalesce(.data$device_description, "No device identified"))

  cli::cli_inform(message = c("v" = "Device DI mapped"))
  return(result)
}
