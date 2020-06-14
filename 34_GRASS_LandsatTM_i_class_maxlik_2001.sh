#!/bin/sh
# GRASS GIS script for processing and visualizing Landsat TM image. Japan, Tokyo Area.
# metadata in GDAL (run by GMT)
gdalinfo p107r035_7dk20010924_z54_61.tif

# import the image subset and display the raster map
r.in.gdal p107r035_7dk20010924_z54_61.tif out=lsat7_2001_61
r.in.gdal p107r035_7dk20010924_z54_62.tif out=lsat7_2001_62
r.in.gdal p107r035_7dp20010924_z54_80.tif out=lsat7_2001_80
r.in.gdal p107r035_7dt20010924_z54_10.tif out=lsat7_2001_10
r.in.gdal p107r035_7dt20010924_z54_20.tif out=lsat7_2001_20
r.in.gdal p107r035_7dt20010924_z54_30.tif out=lsat7_2001_30
r.in.gdal p107r035_7dt20010924_z54_40.tif out=lsat7_2001_40
r.in.gdal p107r035_7dt20010924_z54_50.tif out=lsat7_2001_50
r.in.gdal p107r035_7dt20010924_z54_70.tif out=lsat7_2001_70
g.list rast

#
g.region rast=lsat7_2001_61 -p
r.colors lsat7_2001_10 col=grey
r.colors lsat7_2001_20 col=grey
r.colors lsat7_2001_30 col=grey
d.mon wx0
d.erase
d.rgb b=lsat7_2001_10 g=lsat7_2001_20 r=lsat7_2001_30

r.composite blue=lsat7_2001_10 green=lsat7_2001_20 red=lsat7_2001_30 output=lsat7_2001_rgb
g.list rast
d.mon wx1
d.erase
d.rast lsat7_2001_rgb

#################### i.cluster ####################
# i.cluster - Generates spectral signatures for land cover types in an image using a clustering algorithm. The resulting signature file is used as input for i.maxlik, to generate an unsupervised image classification.

# store VIZ, NIR, MIR into group/subgroup (leaving out TIR)
i.group group=lsat7_2001 subgroup=lsat7_2001 input=lsat7_2001_10,lsat7_2001_20,lsat7_2001_30,lsat7_2001_40,lsat7_2001_50,lsat7_2001_70

# generate signature file and report
i.cluster group=lsat7_2001 subgroup=lsat7_2001 \
  signaturefile=sig_cluster_lsat2001 \
  classes=10 reportfile=rep_clust_lsat2001.txt
  
#################### i.maxlik ####################

# using here the signature file created by i.cluster
i.maxlik group=lsat7_2001 subgroup=lsat7_2001 \
  signaturefile=sig_cluster_lsat2001 \
  output=lsat7_2001_cluster_classes reject=lsat7_2001_cluster_reject --overwrite

# visually check result
d.mon wx0
d.rast.leg lsat7_2001_cluster_classes
d.rast.leg lsat7_2001_cluster_reject

# see how many pixels were rejected at given levels
r.report lsat7_2001_cluster_reject units=k,p

# optionally, filter out pixels with high level of rejection
# here we remove pixels of at least 90% of rejection probability, i.e. categories 12-16
r.mapcalc "lsat7_2001_cluster_classes_filtered = \
           if(lsat7_2001_cluster_reject <= 12, lsat7_2001_cluster_classes, null())"
