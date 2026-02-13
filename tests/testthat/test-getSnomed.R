test_that("getSnomed()", {
  skip_if(!exists("api_key")){
    expect_no_error(dir1 <- downloadSnomedFiles(apiKey = api_key, directory = here::here()))
    expect_no_error(dir2 <- downloadFiles(directory = here::here()))

    expect_no_error(x <- getSnomed(snomedFilesDirectory = dir1,
                                   filesDirectory = dir2,
                                   deviceDI = c("05415067030986", "00811806010366", "13661522039417")))

    expect_equal(x$device_di, c("05415067030986", "00811806010366", "13661522039417"))
    expect_equal(x$brand_name, c("Amplatzer Piccolo™", "AMPLATZER™", "-"))

    unlink("AccessGUDID_Delimited_Full_Release_20260202", recursive = TRUE, force = TRUE)
    unlink("implantable_list", recursive = TRUE, force = TRUE)
  }
})
