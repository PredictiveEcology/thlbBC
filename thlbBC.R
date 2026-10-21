defineModule(sim, list(
  name = "thlbBC",
  description = paste("Timber harvesting land base (THLB) for British Columbia study areas: the official",
                      "provincial THLB where published, else derived from LandR yield tables",
                      "(harvestable if total B reaches `minB` by `age`)."),
  keywords = c("THLB", "harvest", "British Columbia"),
  authors = c(person("Eliot", "McIntire", email = "eliotmcintire@gmail.com", role = c("aut", "cre"))),
  childModules = character(0),
  version = list(thlbBC = "0.0.2"),
  timeframe = as.POSIXlt(c(NA, NA)),
  timeunit = "year",
  citation = list(),
  documentation = list(),
  reqdPkgs = list("SpaDES.core", "bcdata", "data.table", "reproducible", "sf", "terra",
                  "PredictiveEcology/timberSupply@development (>= 0.0.0.9001)"),
  parameters = bindrows(
    defineParameter("age", "integer", 160L, 1L, NA,
                    "Stand age at which the yield-table biomass is compared with `minB`."),
    defineParameter("minB", "numeric", 6000, 0, NA,
                    paste("Total aboveground biomass (g/m2, all species) a yield curve must reach by `age`",
                          "to be harvestable. 6000 g/m2 is about 100 m3/ha, the low-productivity rule of",
                          "the 100 Mile House TSA Timber Supply Review (2024).")),
    defineParameter("minFraction", "numeric", 0.5, 0, 1,
                    "A pixel is in the official THLB if its THLB fraction is at least this."),
    defineParameter("availableTFLs", "character",
                    c("TFL1", "TFL3", "TFL19", "TFL23", "TFL26", "TFL30", "TFL38", "TFL41", "TFL49",
                      "TFL58", "TFL60"), NA, NA,
                    "Tree Farm Licences with a published THLB; other TFLs use the derived THLB.")
  ),
  inputObjects = bindrows(
    expectsInput("rasterToMatch", "SpatRaster", "Template raster."),
    expectsInput("yieldTablesCumulative", "data.table",
                 "Yield curves: yieldTableIndex, age, speciesCode, biomass (g/m2). From Biomass_yieldTables."),
    expectsInput("yieldTablesId", "data.table",
                 "pixelIndex to yieldTableIndex. From Biomass_yieldTables.")
  ),
  outputObjects = bindrows(
    createsOutput("thlb", "SpatRaster", "1 = harvestable, NA = not.")
  )
))

doEvent.thlbBC <- function(sim, eventTime, eventType) {
  switch(
    eventType,
    init = {
      sim$thlb <- timberSupply::thlbBC(sim$rasterToMatch, sim$yieldTablesCumulative, sim$yieldTablesId,
                                       destinationPath = file.path(inputPath(sim), "THLB"),
                                       age = P(sim)$age, minB = P(sim)$minB, minFraction = P(sim)$minFraction,
                                       availableTFLs = P(sim)$availableTFLs)
      terra::writeRaster(sim$thlb, file.path(outputPath(sim), "thlb.tif"), overwrite = TRUE)
    },
    warning(noEventWarning(sim))
  )
  invisible(sim)
}
