
<!-- README.md is generated from README.Rmd. Please edit that file -->

# AccessGUDID <img src="man/figures/logo.png" align="right" height="200"/>

## Installation

You can also install the development version of AccessGUDID

``` r
install.packages("remotes")
remotes::install_github("oxford-pharmacoepi/AccessGUDID")
```

To access to the device UDI - SNOMED mapping, you’ll need a UMLS
Terminology Services API key, which can be obtained following the
instructions in in [this
link](https://documentation.uts.nlm.nih.gov/rest/authentication.html?_gl=1*ozdtii*_ga*MzE4NTczNTgxLjE3MDA2NjYyNTQ.*_ga_7147EPK006*czE3NzEwMDI0NTUkbzE4JGcxJHQxNzcxMDAyNTQyJGozNSRsMCRoMA..*_ga_P1FPTH9PL4*czE3NzEwMDI0NTUkbzE4JGcxJHQxNzcxMDAyNTQyJGozNSRsMCRoMA..)

Please, take into consideration that it may take ~3 days to get an
approved UMLS license.

## Brief description

## Single UDI mapping - Map via AccessGUDID API

``` r
library(AccessGUDID)
library(here)
api_key <- "asdfghjkl"
device_di <- "05415067030986"

result <- getSnomedUsingAPI(apiKey = api_key,
                            deviceDI = device_di)

result
```

    #> # A tibble: 1 × 7
    #>   device_di      brand_name     device_description company_name catalogue_number
    #>   <chr>          <chr>          <chr>              <chr>        <chr>           
    #> 1 05415067030986 Amplatzer Pic… Duct Occluder      ST. JUDE ME… 9-PDAP-03-04-L  
    #> # ℹ 2 more variables: snomed_concept_code <dbl>, snomed_name <chr>

In some cases, API connexion may fail and you may obtain that no SNOMED code was found for a specific device. That is the reason why, if you require the mapping of multiple devices, we recommend using the following option:

## Multiple UDI mapping -
Download AccesGUDID files

First, download the necessary files to do the mapping. These includes:

1.  Devices UDI and their corresponding SNOMED code. Files are
    downloaded from:
    <https://accessgudid.nlm.nih.gov/resources/developers/v3/implant_list_download>.
    To be able to download these files, you’ll need a free UMLS licence
    account. If you don’t have one, follow the instructions in [this
    link](https://documentation.uts.nlm.nih.gov/rest/authentication.html?_gl=1*ozdtii*_ga*MzE4NTczNTgxLjE3MDA2NjYyNTQ.*_ga_7147EPK006*czE3NzEwMDI0NTUkbzE4JGcxJHQxNzcxMDAyNTQyJGozNSRsMCRoMA..*_ga_P1FPTH9PL4*czE3NzEwMDI0NTUkbzE4JGcxJHQxNzcxMDAyNTQyJGozNSRsMCRoMA..).

2.  Devices description, brand, company, and catalogue number. Files are
    downloaded from:
    <https://accessgudid.nlm.nih.gov/download/delimited>

You can download both files manually or using the following functions:

``` r
library(AccessGUDID)
library(here)
dir_snomed <- downloadSnomedFiles(apiKey = api_key,
                                  directory = here())

dir_files <- downloadFiles(directory = here())
```

### Mapping based on a list of Device Identifiers

We can now then use `getSnomed()` function to extract the SNOMED code
for a list of Device Identifiers

``` r
map <- getSnomed(snomedFilesDirectory = dir_snomed,
                 filesDirectory = dir_files,
                 deviceDI = c("05415067030986", "00811806010366", "13661522039417"))

map
```

    #> # A tibble: 3 × 7
    #>   device_di      brand_name     device_description company_name catalogue_number
    #>   <chr>          <chr>          <chr>              <chr>        <chr>           
    #> 1 05415067030986 Amplatzer Pic… Duct Occluder      ST. JUDE ME… 9-PDAP-03-04-L  
    #> 2 00811806010366 AMPLATZER™     Vascular Plug II   AGA MEDICAL… 9-AVP2-006      
    #> 3 13661522039417 -              No device identif… -            -               
    #> # ℹ 2 more variables: snomed_code <dbl>, snomed_name <chr>

### Mapping based on a list of Catalogue Numbers

We can also use `getSnomed()` function to extract the SNOMED code for a
list of Catalogue Numbers

``` r
map <- getSnomed(snomedFilesDirectory = dir_snomed,
                 filesDirectory = dir_files,
                 catalogueNumber = c("9-PDAP-03-04-L", "9-AVP2-006"))

map
```

    #> # A tibble: 3 × 7
    #>   device_di      brand_name     device_description company_name catalogue_number
    #>   <chr>          <chr>          <chr>              <chr>        <chr>           
    #> 1 05415067030986 Amplatzer Pic… Duct Occluder      ST. JUDE ME… 9-PDAP-03-04-L  
    #> 2 00811806010366 AMPLATZER™     Vascular Plug II   AGA MEDICAL… 9-AVP2-006      
    #> 3 13661522039417 -              No device identif… -            -               
    #> # ℹ 2 more variables: snomed_code <dbl>, snomed_name <chr>

Please, note that only a list of Catalogue Numbers or a list of Device
Identifiers can be provided at a time. If you wish to obtain the mapping
for a group of Device Identifiers and a group of Catalogue Numbers, you
will need to run the function separately for each list.
