## R Script for calulating light intensity in a cylindrical object from multiple light sources

### How to use

Run `Rscript light_sources_cylinder.R --light_sources light_sources.csv --output number_illuminated.txt` from the command line for basic usage

**Arguments**

`--diameter` : diameter of the cylinder in cm (default = 70)

`--height` : height of the cylinder in cm (default = 120)

`--intensity_range_low` : minimum value for light intensity (default = 20)

`--intensity_range_high` : maximum value for light intensity (default = 500)

`--light_sources` : csv file with positions and intensities of light sources (e.g. light_sources.csv)

`--output` : file to write number of cubic cm above and below the intensity ranges


**Format of light sources csv file**

the file used as the --light_sources input needs to be formatted as in light_sources.csv:


source_id | intensity | x | y | z
------------ | ------------- | ------------- | ------------- | -------------
source_1 | 10000 | -10 | 120 | 35 
source_2 | 10000 | -10 | 60 | 35 
source_3 | 10000 | -10 | 0 | 35 


**source_id**: any id name for the light source

**intensity**: a value for intensity

**x**: x-axis value

**y**: y-axis value

**z**: z-axis value




## Note 
The coordinates of bottom left corner of the cylinder (or the box containing the cylinder are x=0,y=0,z=0)

Intensity is calculated for the center of each cubic cm.
