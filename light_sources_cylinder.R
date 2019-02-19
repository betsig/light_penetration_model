library(argparse)
options(stringsAsFactors = F)
options(scipen = 999)


# load in script arguments
suppressMessages(library(argparse))

parser <- ArgumentParser()

parser$add_argument("--diameter", type="character", default=70, 
                    help="diameter of the cylinder in cm")
parser$add_argument("--height", type="character", default=120, 
                    help="height of the cylinder in cm")

parser$add_argument("--intensity_range_low", type="character", default=20, 
                    help="minimum value for light intensity")
parser$add_argument("--intensity_range_high", type="character", default=500, 
                    help="maximum value for light intensity")

parser$add_argument("--light_sources", type="character", 
                    help = "csv file with positions and intensities of light sources")
parser$add_argument("--output",type="character", 
                    help="file to write number of cubic cm above and below the intensity ranges")

args <- parser$parse_args()

diameter = as.numeric(args$diameter)
height = as.numeric(args$height)

intensity_range_low = as.numeric(args$intensity_range_low)
intensity_range_high = as.numeric(args$intensity_range_high)

#suppressWarnings({
    light_sources = read.csv(args$light_sources)
#})

###### Run main script

radius = diameter/2
area = (radius**2) * pi

# h = x-axis circle center
# k = y-axis circle center
h=radius
k=radius

# what cubic centimeter points are contained within the circle
is_in_circle = vector()
for(xi in 0:(diameter-1)){
    for(yi in 0:(diameter-1)){
        is_in_circle <- c(is_in_circle,((xi-h)**2 + (yi-k)**2 < radius**2 | 
                                        (xi+1-h)**2 + (yi+1-k)**2 < radius**2 |
                                        (xi+1-h)**2 + (yi-k)**2 < radius**2 |
                                        (xi-h)**2 + (yi+1-k)**2 < radius**2))
    }
}
coord_x1 = rep(0:(diameter-1), diameter)
coord_z1 = rep(0:(diameter-1), each=diameter)
coord_x2 = coord_x1+1
coord_z2 = coord_z1+1

# data.frame for one section (i.e, no y-axis value) of a cylinder
circle_df = data.frame(coord_x1, coord_z1, coord_x2, coord_z2, is_in_circle)
#library(ggplot2)
#ggplot(circle_df, aes(x=coord_x1, y=coord_z1, col=is_in_circle)) + geom_point(shape=15)

# convert to 3d object (cylinder)
cylinder_df = do.call("rbind", replicate(height, circle_df, simplify = FALSE))
cylinder_df$coord_y1 = rep(0:(height-1), each = nrow(circle_df))
cylinder_df$coord_y2 = rep(1:height, each = nrow(circle_df))

# light intensity for each coordinate
cylinder_df$light_intensity = NA

# optical density ??? 
cylinder_df$optical_density = NA

# calculate the distance from a light source to each point in the cylinder
distance_to_points = function(source, points){
    
    if(is.vector(source)){
        source = as.data.frame(matrix(source, ncol=3, byrow = TRUE))
        colnames(source = c("x","y","z"))
    }
    
    points$coord_x = points$coord_x1 + (points$coord_x2 - points$coord_x1)/2
    points$coord_y = points$coord_y1 + (points$coord_y2 - points$coord_y1)/2
    points$coord_z = points$coord_z1 + (points$coord_z2 - points$coord_z1)/2
    
    distance = sqrt((points$coord_x - source$x)**2 +
                        (points$coord_y - source$y)**2 +
                        (points$coord_z - source$z)**2  )

    return(distance)
}

# calculate distance to each point in the cylinder and intensity for each light source
# cumulatively add to light intensity for each light source
intensity_at_point = rep(0, nrow(cylinder_df))
for(lights in 1:nrow(light_sources)){
    
    dist =  distance_to_points(source = light_sources[lights,], points = cylinder_df)
    intensity_at_point  = intensity_at_point + light_sources$intensity[lights] / (dist**2)
    
}

cylinder_df$light_intensity = intensity_at_point

# keep only points WITHIN the cylinder
cylinder_df = cylinder_df[cylinder_df$is_in_circle == TRUE,]

# calculate number of cublic centimeter blocks above/below the intensity ranges
intensity_d = as.data.frame(table(cylinder_df$light_intensity < intensity_range_low | 
          cylinder_df$light_intensity > intensity_range_high))

intensity_d$Var1 = c("light intensity within boundaries", "light intensity outside boundaries")
intensity_d$proportion = intensity_d$Freq / (sum(intensity_d$Freq))
colnames(intensity_d)[1:2] = c("light intensity", "number of cubic centimeters")

#write to file
write.table(intensity_d, file = args$output, sep="\t", row.names = F)

#library(viridis)
#ggplot(cylinder_df[cylinder_df$coord_y1==40 & cylinder_df$is_in_circle,], 
#       aes(x=coord_x1,y=coord_z1, color=light_intensity)) + geom_point(shape=15) + scale_color_viridis_c()

#ggplot(cylinder_df[cylinder_df$coord_z1==35 & cylinder_df$is_in_circle,], 
#       aes(x=coord_x1,y=coord_y1, color=light_intensity)) + geom_point(shape=15) + scale_color_viridis_c()

