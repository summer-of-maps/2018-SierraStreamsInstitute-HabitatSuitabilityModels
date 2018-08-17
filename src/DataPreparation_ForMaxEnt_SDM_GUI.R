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
test_config <- read_csv("FINAL_SUITABILITY_MODELING_CONFIG.csv")

list_rasters=list()

projection <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

e <- extent(-121.27, -120.4, 37.3, 38.3)

#for loop that extracts csv line for each species
  
  #process for VARIABLE 2 - VEGETATION COMMUNITY
    #read in spatial data
    hold <- toString(colnames(cf2[2]))
    assign(paste0(hold, "_raw"),
           sf::st_read(dsn="DATA FILES", layer=hold))
    
    # - convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(veg_community_raw)
    res(hold.raster) <- 20
    assign(paste0("veg", "_rasterized"),
           fasterize(veg_community_raw, hold.raster, 'CWHR'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("veg_", "projected"),
           projectRaster(veg_rasterized,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("veg_community_final"), veg_projected)
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, veg_community_final)
    
    #printing for demonstration only
    print(list_rasters)
    
    
  #process for VARIABLE 3, VARIABLE 4 - ELEVATION
    # read in raster data
    filename <- toString(colnames(cf2[3]))
    assign(paste0("elev_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("elev_", "projected"),
           projectRaster(elev_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("elev_final"), elev_projected)
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, elev_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  #process for VARIABLE 5, VARIABLE 6 - SLOPE
    # read in raster data
    filename <- toString(colnames(cf2[5]))
    assign(paste0("slope_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("slope_", "projected"), 
           projectRaster(slope_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("slope_final"), slope_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, slope_final)
    
    #printing for demonstration only
    print(list_rasters)
    

  #process for VARIABLE 7 - VERNAL POOL
    #read in spatial data
    hold <- toString(colnames(cf2[7]))
    assign(paste0(hold, "_raw"), 
           sf::st_read(dsn="DATA FILES", layer=hold))
  
    # convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(vernal_raw)
    res(hold.raster) <- 20
    assign(paste0("vernal", "_rasterized"), 
           fasterize(vernal_raw, hold.raster, 'VernalPool'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("vernal_", "reclass"), reclassify(vernal_rasterized, ReclassMatrix,include.lowest=FALSE, right=TRUE))
    assign(paste0("vernal_", "projected"), 
           projectRaster(vernal_reclass,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("vernal_final"), vernal_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, vernal_final)
    
    #printing for demonstration only
    print(list_rasters)

  #process for VARIABLE 8, VARIABLE 9 - CANOPY/SHADE
    # read in raster data
    filename <- toString(colnames(cf2[8]))
    assign(paste0("canopy_", "raw"), raster(filename))
    
    # extract correct values using parameters from file
    assign(paste0("canopy_", "projected"), 
           projectRaster(canopy_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("canopy_final"), canopy_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, canopy_final)
    
    #printing for demonstration only
    print(list_rasters)

  #process for VARIABLE 10 - LAND COVER
    #read in spatial data
    hold <- toString(colnames(cf2[10]))
    assign(paste0(hold, "_raw"),
           sf::st_read(dsn="DATA FILES", layer=hold))
    
    # - convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(landcover_raw)
    res(hold.raster) <- 20
    assign(paste0("landcover", "_rasterized"),
           fasterize(landcover_raw, hold.raster, 'gridcode'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("landcover_", "projected"),
           projectRaster(landcover_rasterized,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("landcover_final"), landcover_projected)
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, landcover_final)
    
    #printing for demonstration only
    print(list_rasters)
  
  #process for VARIABLE 11 - PROXIMITY TO WATER
    # read in raster data
    filename <- toString(colnames(cf2[11]))
    assign(paste0("prox_water_", "raw"), raster(filename))
    
    assign(paste0("prox_water_", "projected"), 
           projectRaster(prox_water_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("prox_water_final"), prox_water_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, prox_water_final)
    
    #printing for demonstration only
    print(list_rasters)

  #process for VARIABLE 12 - PROXIMITY TO ROADS
    # read in raster data
    filename <- toString(colnames(cf2[12]))
    assign(paste0("prox_roads_", "raw"), raster(filename))

    assign(paste0("prox_roads_", "projected"), 
           projectRaster(prox_roads_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("prox_roads_final"), prox_roads_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, prox_roads_final)
    
    #printing for demonstration only
    print(list_rasters)

  #process for VARIABLE 13 - PROXIMITY TO DEVELOPMENT
    # read in raster data
    filename <- toString(colnames(cf2[13]))
    assign(paste0("prox_dev_", "raw"), raster(filename))
    
    assign(paste0("prox_dev_", "projected"), 
           projectRaster(prox_dev_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("prox_dev_final"), prox_dev_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, prox_dev_final)
    
    #printing for demonstration only
    print(list_rasters)
  
  #process for VARIABLE 14 - PROXIMITY TO AGRICULTURE
    # read in raster data
    filename <- toString(colnames(cf2[14]))
    assign(paste0("prox_agri_", "raw"), raster(filename))
    
    assign(paste0("prox_agri_", "projected"), 
           projectRaster(prox_agri_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("prox_agri_final"), prox_agri_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, prox_agri_final)
    
    #printing for demonstration only
    print(list_rasters)
  
  #process for VARIABLE 15, VARIABLE 16 - PRECIPITATION
    # read in raster data
    filename <- toString(colnames(cf2[15]))
    assign(paste0("precip_", "raw"), raster(filename))
    
    assign(paste0("precip_", "projected"), 
           projectRaster(precip_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("precip_final"), precip_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, precip_final)
    
    #printing for demonstration only
    print(list_rasters)
  
  #process for VARIABLE 17, VARIABLE 18 - TEMPERATURE
    # read in raster data
    filename <- toString(colnames(cf2[17]))
    assign(paste0("temp_", "raw"), raster(filename))
    
    assign(paste0("temp_", "projected"), 
           projectRaster(temp_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("temp_final"), temp_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, temp_final)
    
    #printing for demonstration only
    print(list_rasters)
  
  #process for VARIABLE 19 - SOIL DEPTH
    # read in raster data
    filename <- toString(colnames(cf2[19]))
    assign(paste0("soildepth_", "raw"), raster(filename))
    
    assign(paste0("soildepth_", "projected"), 
           projectRaster(soildepth_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("soildepth_final"), soildepth_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, soildepth_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  #process for VARIABLE 20 - FIRE RISK
    # read in raster data
    filename <- toString(colnames(cf2[20]))
    assign(paste0("fire_risk_", "raw"), raster(filename))
    
    assign(paste0("fire_risk_", "projected"), 
           projectRaster(fire_risk_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("fire_risk_final"), fire_risk_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, fire_risk_final)
    
    #printing for demonstration only
    print(list_rasters)
  
  #process for VARIABLE 21 - SLOPE
    # read in raster data
    filename <- toString(colnames(cf2[21]))
    assign(paste0("north_slopes_", "raw"), raster(filename))
    
    assign(paste0("north_slopes_", "projected"), 
           projectRaster(north_slopes_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("north_slopes_final"), north_slopes_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, north_slopes_final)
    
    #printing for demonstration only
    print(list_rasters)
  
  #process for VARIABLE 22 - SOIL DRAINAGE
    # read in raster data
    filename <- toString(colnames(cf2[22]))
    assign(paste0("soil_drain_", "raw"), raster(filename))
    
    assign(paste0("soil_drain_", "projected"), 
           projectRaster(soil_drain_raw,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("soil_drain_final"), soil_drain_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, soil_drain_final)
    
    #printing for demonstration only
    print(list_rasters)
    
  #process for VARIABLE 23 - SOIL TYPE
    #read in spatial data
    hold <- toString(colnames(cf2[23]))
    assign(paste0(hold, "_raw"), 
           sf::st_read(dsn="DATA FILES", layer=hold))

    # - convert new spatial vector data to raster using rgdal and fasterize
    require(raster)
    hold.raster <- raster()
    extent(hold.raster) <- extent(soiltype_raw)
    res(hold.raster) <- 20
    assign(paste0("soiltype", "_rasterized"), 
           fasterize(soiltype_raw, hold.raster, 'GabSerp'))
    
    # - convert raster values and apply weights, if relevant
    assign(paste0("soiltype_", "projected"), 
           projectRaster(soiltype_rasterized,crs=projection))
    
    # create variable equal to final raster
    assign(paste0("soiltype_final"), soiltype_projected) 
    
    #add name of new raster into list of rasters
    list_rasters <- c(list_rasters, soiltype_final)
    
    #printing for demonstration only
    print(list_rasters)

canopy_final_x <- resample(canopy_final, elev_final)
landcover_final_x <- resample(landcover_final, elev_final)
north_slopes_final_x <- resample(north_slopes_final, elev_final)
precip_final_x <- resample(precip_final, elev_final)
prox_agri_final_x <- resample(prox_agri_final, elev_final)
prox_dev_final_x <- resample(prox_dev_final, elev_final)
prox_water_final_x <- resample(prox_water_final, elev_final)
prox_roads_final_x <- resample(prox_roads_final, elev_final)
slope_final_x <- resample(slope_final, elev_final)
soildepth_final_x <- resample(soildepth_final, elev_final)
temp_final_x <- resample(temp_final, elev_final)
veg_community_final_x <- resample(veg_community_final, elev_final)
elev_final_x <- elev_final

canopy_tend <- extend(canopy_final_x, e, value=NA)
elev_tend <- extend(elev_final_x, e, value=NA)
northslopes_tend <- extend(north_slopes_final_x, e, value=NA)
precip_tend <- extend(precip_final_x, e, value=NA)
prox_agri_tend <- extend(prox_agri_final_x, e, value=NA)
prox_water_tend <- extend(prox_water_final_x, e, value=NA)
prox_roads_tend <- extend(prox_roads_final_x,  e, value=NA)
slope_tend <- extend(slope_final_x, e, value=NA)
temp_tend <- extend(temp_final_x, e, value=NA)
veg_tend <- extend(veg_community_final_x, e, value=NA)
  
  # prefix = "final_"
  # suffix = "_suit_YAY.tif"
  # outname <- paste0(prefix, s, suffix)
  # list.final = list("final" = assign(paste0("finalsum_",s), sum(pancakes, na.rm=TRUE)))
  # writeRaster(list.final$final, outname, options=c('TFW=YES'), overwrite=TRUE)
  
  
  list_rasters=list()
  list.final=list()
  

  
