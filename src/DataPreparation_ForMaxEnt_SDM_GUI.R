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
test_config <- read_csv("CONFIG_SCALED.csv")

list_rasters=list()

projection <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

e <- extent(-121.27, -120.4, 37.3, 38.3)

#for loop that extracts csv line for each species

  s <- test_config$species[1]
  
  cf2 <- test_config %>% filter(species == s)
  
  print(cf2)
  
  #process for VARIABLE VEGETATION COMMUNITY
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
    
    
  #process for VARIABLE ELEVATION
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
    
  #process for VARIABLE SLOPE
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

  #process for VARIABLE LAND COVER
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
  
  #process for VARIABLE PRECIPITATION
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
  
  #process for VARIABLE SLOPE
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
  

landcover_final_x <- resample(landcover_final, elev_final)
precip_final_x <- resample(precip_final, elev_final)
slope_final_x <- resample(slope_final, elev_final)
veg_community_final_x <- resample(veg_community_final, elev_final)
elev_final_x <- elev_final

canopy_tend <- extend(canopy_final_x, e, value=NA)
elev_tend <- extend(elev_final_x, e, value=NA)
precip_tend <- extend(precip_final_x, e, value=NA)
slope_tend <- extend(slope_final_x, e, value=NA)
veg_tend <- extend(veg_community_final_x, e, value=NA)
  
writeRaster(landcover_tend, filename=”landcover_output.asc”, format=’ascii’, overwrite=TRUE)
writeRaster(precip_tend, filename=”precip_output.asc”, format=’ascii’, overwrite=TRUE)
writeRaster(slope_tend, filename=”slope_output.asc”, format=’ascii’, overwrite=TRUE)
writeRaster(veg_tend, filename=”veg_output.asc”, format=’ascii’, overwrite=TRUE)
writeRaster(elev_tend, filename=”elev_output.asc”, format=’ascii’, overwrite=TRUE)

  
list_rasters=list()
list.final=list()
  

  
