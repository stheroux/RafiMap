#interactive map for Rafi 

library(ggplot2); library(rgdal); library(ggmap); library(sp); library(rgdal)
library(rgeos);library(maptools);library(leaflet);library(shiny);library(maptools);library(PBSmapping)
library(shapefiles)
library(sp)
library(mapview)
library(raster)
library(RColorBrewer)

source("points_to_line.R")

suzdir<-"/Volumes/Databases/SWAMP_SMT/NHD18_hydrography"
setwd("~/Documents/R/MAPS/NHDplus/")
comid.pred.df<-read.csv("csci_qpreds.csv")

# have you run this script before? 
runbefore=T

###############################################
# Get data ----------
###############################################

if (runbefore==F) {

#import nhd 
nhd.r9<-readOGR(dsn=suzdir, layer="nhdflowline_RB9") #Layer: Name of the shapefile, no extension
nhd.r9@data$id<-rownames(nhd.r9@data)
nhd.r9.fort<-fortify(nhd.r9, region="COMID") #COMID identifies each unique object in the shapefile
nhd.r9.fort<-plyr::join(nhd.r9.fort, nhd.r9@data)
nhd.r9.fort<-plyr::join(nhd.r9.fort, comid.pred.df) #Add whaterver new data you have
nhd.r9.fort<-subset(nhd.r9.fort, q0_05!="NA") #remove NAs

# assign likely state q50
nhd.r9.fort$q50state<-c()
nhd.r9.fort$q50state<-
  ifelse(nhd.r9.fort$q0_5<=0.63,"Very poor",
         ifelse(nhd.r9.fort$q0_5<=0.79,"Poor",
                ifelse(nhd.r9.fort$q0_5<=0.92,"Fair",
                       ifelse(nhd.r9.fort$q0_5>0.92,"Good",
                              "NAZ"))))

nhd.r9.fort$q50state<-factor(nhd.r9.fort$q50state, levels=c("Very poor","Poor","Fair","Good"))

#export 
write.csv(nhd.r9.fort, "nhd.r9.fort.csv") }

if (runbefore==T) {nhd.r9.fort<-read.csv("nhd.r9.fort.csv")}

#########################################
# PLOT ------------
#########################################

# make small test file
test<-nhd.r9.fort[1:5000,]

#or run all the data
test<-nhd.r9.fort

# get your data into lines 
df<-droplevels(subset(test, order==c("1"))) #collapse df to just one instance per COMID 
sl <- points_to_line(test, "long", "lat", "COMID")
sldf<-SpatialLinesDataFrame(sl, df, match.ID = F)
proj4string(sldf) <- CRS("+init=epsg:4269")

#mapview(sldf)

pal <- colorRampPalette(brewer.pal(9, "BrBG"))

mapview(sldf, 
        zcol = c("q0_1","q0_2","q0_3","q0_4","q0_5","q0_6", "q0_7","q0_8", "q0_9"),
        at = seq(0.2, 1.4, 0.2), legend = T)







