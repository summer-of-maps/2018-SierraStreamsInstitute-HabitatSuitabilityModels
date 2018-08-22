# ReadMe - Using R for Habitat Suitability Modeling and Data Prep for MaxEnt SDM

This ReadMe has two parts. The first deals with the habitat suitability modeling R script and config file, while the second deals with the DataPreparation_ForMaxEnt_SDM_GUI.R file used for species distribution modeling. Both are located in 'src' in this repository. 

### Part 1: CREATING A HABITAT SUITABILITY MODEL FROM .TIFF RASTER and .SHP VECTOR DATA FOR MULTIPLE SPECIES

This ReadMe document is designed to allow the user to use and modify the R script "SUITABILITY_MODELING_FINAL_SCRIPT.R" and the associated CSV config file "SUITABILITY_MODELING_FINAL_CONFIG.CSV".

It is designed to produce .tif raster files displaying the habitat suitability of species listed in the config file. The following 10 species native to the Bear River Watershed of California are used as examples throughout.
	1. Stebbins's morning glory
	2. Cantelow's lewisia
	3. Pine hill flannelbush
	4. Yellow warbler
	5. Tricolored blackbird
	6. Bank swallow
	7. Western pond turtle
	8. Giant garter snake
	9. Sierra Nevada mountain beaver
	10. Dwarf dowingia

*******************************************************************

#### FILE SETUP

Create a folder named SuitMod or similar and place in this folder the SUITABILITY_MODELING_FINAL_* R script and CSV config file.

Additionally, include raster .tif files in the SuitMod folder. The files below are given as examples.

	elevation_min.tif
	elevation_max.tif
	slope_min.tif
	slope_max.tif
	canopy_min.tif
	canopy_max.tif
	prox_water.tif
	prox_roads.tif
	prox_dev.tif
	prox_agri.tif
	precip_min.tif
	precip_max.tif
	temp_min.tif
	temp_max.tif
	soildepth.tif
	fire_risk.tif
	north_slopes.tif
	soil_drain.tif

Within the SuitMod folder, create a folder named "DATA FILES". Inside DATA FILES, place any shapefiles with all associated files. The files below are given as examples:
	veg_community.shp
	vernal_yesno.shp
	landcover.shp
	soiltype.shp
	sandyloamy_soils.shp
	claysilt_soils.shp

Each of these example data files corresponds to a section of the script. For each of your data files, you must modify the corresponding section of the script. Unused portions of the script should be deleted or commented out.

To run, set up an R project with the SuitMod folder as working directory.

***************************************************************************

#### RUNNING THE SCRIPT:

The script depends on the following R packages:

raster
rgdal
sf
tidyverse
fasterize

From those scripts, it uses the following libraries:

sf
raster
rgdal
tidyverse
rgeos
scales
fasterize

At the top of the script (lines 1-5) is the code to install those packages. If they are not already installed, do so before running the script.

Other than that, the unmodified script should run smoothly. It will take at least 10 minutes to run.

***************************************************************************

#### MODFIYING THE SCRIPT:

You may wish to modify the script to add additional factors or to change the parameters in the config file for the factors already included, such as elevation or temperature. 

##### To add a factor:

	Add an additional column to the config file. 

	For factors with raster files, make sure the raster is in a .tif format and name the column the name of the raster. 
		Include the ".tif" extension. Place the file in the SuitMod folder.

	For factors with vector files, make sure the vector is in a .shp format and name the column the name of the vector.
		*DO NOT* include the ".shp" extension. Place the file in the DATA FILES folder.

	Fill in the new config with for parameters for each species. 

		For numeric parameters, do not include ">" or "<" or similar - just the numbers.

	For species without parameters for that factor, type "NA", all caps. Do not leave any box in the config blank.

	Save the config file and close.

	You must now modify the script itself.

	For each factor/column of the config file, the script includes a section of code dealing with that factor (column of the config file). 

	You will add a new section for your new factor.

	For raster factors, it is probably easiest to copy and paste the second section (elevation) from the existing script.
		
	For vector factors, copy, paste, and modify the vegetation-communities section of the existing script.

	Add your new section to the end of the for-loop, and modify the variable names to match your config file. 
		Reading the existing script should give you an idea of how a new code block should look.

	Save the script and the new config file and run!

	Do not modify the script outside of the for-loop. It shouldn't be necessary when adding a new factor.


##### To change the parameters on existing factors:

	This is much easier. Just edit the config file, save, and re-run the script in full!


##### To add an additional species:
	
	Edit the config file to include an additional row.

	Make sure the species name is a single word in the first column.

	Add parameters for the new species for each factor for which you have them. For factors not relevant to the species, put NA. 

	Save the edited config file and run the script again! 



	# 2018-SierraStreamsInstitute-HabitatSuitabilityModels
