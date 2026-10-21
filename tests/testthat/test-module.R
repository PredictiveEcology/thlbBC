## The module on a real BC study area. Downloads one TSA geodatabase (tsa23.zip, about 4 MB).

## Run the module's init on the study area.
runModule <- function(params = list()) {
  rtm <- bcStudyArea()
  sim <- SpaDES.core::simInit(
    times = list(start = 2020, end = 2020),
    modules = moduleName,
    paths = testPaths,
    params = setNames(list(params), moduleName),
    objects = c(list(rasterToMatch = rtm), toyYieldTables(rtm)))
  SpaDES.core::spades(sim, debug = FALSE)
}

test_that("thlb is 1 or NA on the grid of rasterToMatch, and is written to outputs", {
  skipUnlessBC()
  testthat::skip_if_offline("www.for.gov.bc.ca")
  sim <- runModule()
  expect_s4_class(sim$thlb, "SpatRaster")
  expect_true(terra::compareGeom(sim$thlb, sim$rasterToMatch))
  v <- terra::values(sim$thlb)[, 1]
  expect_true(all(is.na(v) | v == 1))
  expect_true(any(v %in% 1))
  expect_true(file.exists(file.path(SpaDES.core::outputPath(sim), "thlb.tif")))
})
