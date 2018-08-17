#install.packages("raster")
#install.packages("rgdal")
#install.packages("sf")
#install.packages("tidyverse")
#install.packages("fasterize")
library(sf)
library(raster)
library(rgdal)
library(tidyverse)
library(rgeos)
library(scales)
library(fasterize)

#read in config file
config <- read_csv("SUITABILITY_MODELING_FINAL_CONFIG.csv")

list_rasters=list()

projection <- "+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000
+ +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

ProjParams <- raster('projection_params.tif')

#for loop that extracts csv line for each species
for(i in seq_along(test_config$species)){
  
  s <- config$species[i]
  
  cf2 <- config %>% filter(species == s)
  
  print(cf2)
  
  ReclassMatrix = matrix( c(0.000001, 10000, 1), nrow=1, ncol=3, byrow=TRUE)
  
  #process for VARIABLE 2 - VEGETATION COMMUNITY
  if (!is.na(cf2$veg_community)){
    print(paste("veg_community is not na for", s))
    
    #read in spatial data
    hold <- toString(colnames(cf2[2]))
    assign(paste0(hold, "_raw"),
           sf::st_read(dsn="DATA FILES", layer=hold))
    
    # select values from spatial vector data that conform with requirements per species
    assign(paste0("veg", "_params"), unlist(strsplit(cf2[[2]], ",")))
    assign(paste0("veg", "_extract"),
           filter(veg_community_raw, CWHR %in% veg_params))
    
    # - convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(veg_extract)
    res(hold.raster) <- 20
    assign(paste0("veg", "_rasterized"),
           fasterize(veg_extract, hold.raster, 'CWHR'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("veg_", "reclass"), reclassify(veg_rasterized, ReclassMatrix,include.lowest=FALSE, right=TRUE))
    assign(paste0("veg_", "projected"),
           projectRaster(veg_reclass,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("veg_community_final"), veg_projected)
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, veg_community_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("vegetation community is not a known parameter for", s))
  }
  
  #process for VARIABLE 3, VARIABLE 4 - ELEVATION
  if (!is.na(cf2$elevation_max.tif) | !is.na(cf2$elevation_min.tif)){
    
    print(paste("elevation_max or elevation_min is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[3]))
    assign(paste0("elev_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("elev_", "extract"),
           elev_raw < as.integer(cf2$elevation_max.tif)
           &
             elev_raw > as.integer(cf2$elevation_min.tif))
    assign(paste0("elev_", "projected"),
           projectRaster(elev_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("elev_final"), elev_projected)
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, elev_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("elevation is not a known parameter for", s))
  }
  
  #process for VARIABLE 5, VARIABLE 6 - SLOPE
  if (!is.na(cf2$slope_min.tif) | !is.na(cf2$slope_max.tif)){
    
    print(paste("slope_max or slope_min is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[5]))
    assign(paste0("slope_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("slope_", "extract"),
           slope_raw < as.integer(cf2$slope_max.tif) 
           & 
             slope_raw > as.integer(cf2$slope_min.tif))
    assign(paste0("slope_", "projected"), 
           projectRaster(slope_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("slope_final"), slope_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, slope_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("slope is not a known parameter for", s))
  }
  
  #process for VARIABLE 7 - VERNAL POOLS
  if (!is.na(cf2$vernal_yesno)){
    print(paste("vernal pools is not na for", s))
    
    #read in spatial data
    hold <- toString(colnames(cf2[7]))
    assign(paste0(hold, "_raw"), 
           sf::st_read(dsn="DATA FILES", layer=hold))
    
    # select values from spatial vector data that conform with requirements per species
    vernal_params = "Y"
    assign(paste0("vernal", "_extract"), 
           filter(vernal_yesno_raw, VernalPool %in% vernal_params))    
    
    # convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(vernal_extract)
    res(hold.raster) <- 20
    assign(paste0("vernal", "_rasterized"), 
           fasterize(vernal_extract, hold.raster, 'VernalPool'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("vernal_", "reclass"), reclassify(vernal_rasterized, ReclassMatrix,include.lowest=FALSE, right=TRUE))
    assign(paste0("vernal_", "projected"), 
           projectRaster(vernal_reclass,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("vernal_final"), vernal_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, vernal_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("vernal pools is not a known parameter for", s))
  }
  
  
  #process for VARIABLE 8, VARIABLE 9 - CANOPY/SHADE
  if (!is.na(cf2$canopy_min.tif) | !is.na(cf2$canopy_max.tif)){
    
    print(paste("canopy_max or canopy_min is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[8]))
    assign(paste0("canopy_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("canopy_", "extract"),
           canopy_raw <= as.integer(cf2$canopy_max.tif) 
           & 
             canopy_raw >= as.integer(cf2$canopy_min.tif))
    assign(paste0("canopy_", "projected"), 
           projectRaster(canopy_extract,ProjParams))
    assign(paste0("canopy_", "reclass"), reclassify(canopy_projected, ReclassMatrix,include.lowest=FALSE, right=TRUE))
    
    # create variable equal to final raster
    assign(paste0("canopy_final"), canopy_reclass) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, canopy_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("canopy cover is not a known parameter for", s))
  }
  
  #process for VARIABLE 10 - LAND COVER
  if (!is.na(cf2$landcover)){
    print(paste("land cover is not na for", s))
    
    #read in spatial data
    hold <- toString(colnames(cf2[10]))
    assign(paste0(hold, "_raw"),
           sf::st_read(dsn="DATA FILES", layer=hold))
    
    # select values from spatial vector data that conform with requirements per species
    assign(paste0("landcover", "_params"), unlist(strsplit(cf2[[10]], ",")))
    assign(paste0("landcover", "_extract"),
           filter(landcover_raw, gridcode %in% landcover_params))
    
    # - convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(landcover_extract)
    res(hold.raster) <- 20
    assign(paste0("landcover", "_rasterized"),
           fasterize(landcover_extract, hold.raster, 'gridcode'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("landcover_", "reclass"), reclassify(landcover_rasterized, ReclassMatrix,include.lowest=FALSE, right=TRUE))
    assign(paste0("landcover_", "projected"),
           projectRaster(landcover_reclass,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("landcover_final"), landcover_projected)
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, landcover_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("land cover is not a known parameter for", s))
  }
  
  #process for VARIABLE 11 - PROXIMITY TO WATER
  if (!is.na(cf2$prox_water.tif)){
    
    print(paste("prox_water is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[11]))
    assign(paste0("prox_water_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("prox_water_", "extract"),
           prox_water_raw <= as.integer(cf2$prox_water.tif))
    
    assign(paste0("prox_water_", "projected"), 
           projectRaster(prox_water_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("prox_water_final"), prox_water_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, prox_water_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("proximity to water is not a known parameter for", s))
  }
  
  #process for VARIABLE 12 - PROXIMITY TO ROADS
  if (!is.na(cf2$prox_roads.tif)){
    
    print(paste("prox_roads is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[12]))
    assign(paste0("prox_roads_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("prox_roads_", "extract"),
           prox_roads_raw >= as.integer(cf2$prox_roads.tif))
    
    assign(paste0("prox_roads_", "projected"), 
           projectRaster(prox_roads_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("prox_roads_final"), prox_roads_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, prox_roads_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("proximity to roads is not a known parameter for", s))
  }
  
  #process for VARIABLE 13 - PROXIMITY TO DEVELOPMENT
  if (!is.na(cf2$prox_dev.tif)){
    
    print(paste("prox_dev is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[13]))
    assign(paste0("prox_dev_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("prox_dev_", "extract"),
           prox_dev_raw >= as.integer(cf2$prox_dev.tif))
    
    assign(paste0("prox_dev_", "projected"), 
           projectRaster(prox_dev_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("prox_dev_final"), prox_dev_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, prox_dev_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("proximity to development is not a known parameter for", s))
  }
  
  #process for VARIABLE 14 - PROXIMITY TO AGRICULTURE
  if (!is.na(cf2$prox_agri.tif)){
    
    print(paste("prox_agri is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[14]))
    assign(paste0("prox_agri_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("prox_agri_", "extract"),
           prox_agri_raw <= as.integer(cf2$prox_agri.tif))
    
    assign(paste0("prox_agri_", "projected"), 
           projectRaster(prox_agri_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("prox_agri_final"), prox_agri_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, prox_agri_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("proximity to agriculture is not a known parameter for", s))
  }
  
  #process for VARIABLE 15, VARIABLE 16 - PRECIPITATION
  if (!is.na(cf2$precip_min.tif) | !is.na(cf2$precip_max.tif)){
    
    print(paste("precip_max or precip_min is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[15]))
    assign(paste0("precip_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("precip_", "extract"),
           precip_raw <= as.integer(cf2$precip_max.tif) 
           & 
             precip_raw >= as.integer(cf2$precip_min.tif))
    assign(paste0("precip_", "projected"), 
           projectRaster(precip_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("precip_final"), precip_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, precip_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("precipitation is not a known parameter for", s))
  }
  
  #process for VARIABLE 17, VARIABLE 18 - TEMPERATURE
  if (!is.na(cf2$temp_min.tif) | !is.na(cf2$temp_max.tif)){
    
    print(paste("temp_max or temp_min is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[17]))
    assign(paste0("temp_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("temp_", "extract"),
           temp_raw <= as.integer(cf2$temp_max.tif) 
           & 
             temp_raw >= as.integer(cf2$temp_min.tif))
    assign(paste0("temp_", "projected"), 
           projectRaster(temp_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("temp_final"), temp_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, temp_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("temperature is not a known parameter for", s))
  }
  
  #process for VARIABLE 19 - SOIL DEPTH
  if (!is.na(cf2$soildepth.tif)){
    
    print(paste("soildepth is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[19]))
    assign(paste0("soildepth_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("soildepth_", "extract"),
           soildepth_raw >= as.integer(cf2$soildepth.tif))
    
    assign(paste0("soildepth_", "projected"), 
           projectRaster(soildepth_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("soildepth_final"), soildepth_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, soildepth_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("soil depth is not a known parameter for", s))
  }
  
  #process for VARIABLE 20 - FIRE RISK
  if (!is.na(cf2$fire_risk.tif)){
    
    print(paste("fire_risk is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[20]))
    assign(paste0("fire_risk_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("fire_risk_", "extract"),
           fire_risk_raw >= as.integer(cf2$fire_risk.tif))
    
    assign(paste0("fire_risk_", "projected"), 
           projectRaster(fire_risk_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("fire_risk_final"), fire_risk_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, fire_risk_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("Fire risk is not a known parameter for", s))
  }
  
  #process for VARIABLE 21 - SLOPE
  if (!is.na(cf2$north_slopes.tif)){
    
    print(paste("north_slopes is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[21]))
    assign(paste0("north_slopes_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("north_slopes_", "extract"),
           north_slopes_raw == as.integer(cf2$north_slopes.tif))
    
    assign(paste0("north_slopes_", "projected"), 
           projectRaster(north_slopes_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("north_slopes_final"), north_slopes_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, north_slopes_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("Slope is not a known parameter for", s))
  }
  
  #process for VARIABLE 22 - SOIL DRAINAGE
  if (!is.na(cf2$soil_drain.tif)){
    
    print(paste("soil_drain is not na for", s))
    
    # read in raster data
    filename <- toString(colnames(cf2[22]))
    assign(paste0("soil_drain_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("soil_drain_", "extract"),
           soil_drain_raw <= as.integer(cf2$soil_drain.tif))
    
    assign(paste0("soil_drain_", "projected"), 
           projectRaster(soil_drain_extract,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("soil_drain_final"), soil_drain_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, soil_drain_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("Soil drainage is not a known parameter for", s))
  }
  
  #process for VARIABLE 23 - SOIL TYPE
  if (!is.na(cf2$soiltype)){
    print(paste("soiltype is not na for", s))
    
    #read in spatial data
    hold <- toString(colnames(cf2[23]))
    assign(paste0(hold, "_raw"), 
           sf::st_read(dsn="DATA FILES", layer=hold))
    
    # select values from spatial vector data that conform with requirements per species
    assign(paste0("soiltype", "_params"), unlist(strsplit(cf2[[23]], ",")))
    assign(paste0("soiltype", "_extract"), 
           filter(soiltype_raw, GabSerp %in% soiltype_params))    
    
    # - convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(soiltype_extract)
    res(hold.raster) <- 20
    assign(paste0("soiltype", "_rasterized"), 
           fasterize(soiltype_extract, hold.raster, 'GabSerp'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("soiltype_", "reclass"), reclassify(soiltype_rasterized, ReclassMatrix,include.lowest=FALSE, right=TRUE))
    assign(paste0("soiltype_", "projected"), 
           projectRaster(soiltype_reclass,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("soiltype_final"), soiltype_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, soiltype_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("soil type is not a known parameter for", s))
  }
  
  #process for VARIABLE 24 - SANDY/LOAMY SOILS
  if (!is.na(cf2$sandyloamy_soils)){
    print(paste("sandyloamy_soils is not na for", s))
    
    #read in spatial data
    hold <- toString(colnames(cf2[24]))
    assign(paste0(hold, "_raw"), 
           sf::st_read(dsn="DATA FILES", layer=hold))
    
    # - convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(sandyloamy_soils_raw)
    res(hold.raster) <- 20
    assign(paste0("sandyloamy_soils", "_rasterized"), 
           fasterize(sandyloamy_soils_raw, hold.raster, 'taxpartsiz'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("sandyloamy_soils_", "reclass"), reclassify(sandyloamy_soils_rasterized, ReclassMatrix,include.lowest=FALSE, right=TRUE))
    assign(paste0("sandyloamy_soils_", "projected"), 
           projectRaster(sandyloamy_soils_reclass,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("sandyloamy_soils_final"), sandyloamy_soils_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, sandyloamy_soils_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("Sandy/loamy soil is not a known parameter for", s))
  }
  
  #process for VARIABLE 25 - CLAY/SILT SOILS
  if (!is.na(cf2$claysilt_soils)){
    print(paste("claysilt_soils is not na for", s))
    
    #read in spatial data
    hold <- toString(colnames(cf2[25]))
    assign(paste0(hold, "_raw"), 
           sf::st_read(dsn="DATA FILES", layer=hold))
    
    # - convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(claysilt_soils_raw)
    res(hold.raster) <- 20
    assign(paste0("claysilt_soils", "_rasterized"), 
           fasterize(claysilt_soils_raw, hold.raster, 'taxpartsiz'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("claysilt_soils_", "reclass"), reclassify(claysilt_soils_rasterized, ReclassMatrix,include.lowest=FALSE, right=TRUE))
    assign(paste0("claysilt_soils_", "projected"), 
           projectRaster(claysilt_soils_reclass,ProjParams))
    
    # create variable equal to final raster
    assign(paste0("claysilt_soils_final"), claysilt_soils_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, claysilt_soils_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  } else {
    
    print(paste("Clay/silt soil is not a known parameter for", s))
  }
  
  
  #After all variables loaded and rasterized, sum them using these functions!
  
  extend_all =
    function(rasters){
      extent(Reduce(extend,rasters))
    }
  
  sum_all = 
    function(rasters, extent){
      re = lapply(rasters, function(r){extend(r, extent)})
      Reduce("+",re)
    } 
  
  print(list_rasters)
  
  pancakes <- stack(list_rasters)
  prefix = "final_"
  suffix = "_suit_YAY.tif"
  outname <- paste0(prefix, s, suffix)
  list.final = list("final" = assign(paste0("finalsum_",s), sum(pancakes, na.rm=TRUE)))
  writeRaster(list.final$final, outname, options=c('TFW=YES'), overwrite=TRUE)

  
  list_rasters=list()
  list.final=list()
  
}