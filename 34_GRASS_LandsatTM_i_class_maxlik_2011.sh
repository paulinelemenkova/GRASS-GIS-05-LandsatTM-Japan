#!/bin/sh
# GRASS GIS script for processing and visualizing Landsat TM image. Japan, Tokyo Area.
gdalinfo L71107035_03520110413_B61.TIF
# import the image subset and display the raster map
r.in.gdal L71107035_03520110413_B61.TIF out=lsat7_2011_61
r.in.gdal L72107035_03520110413_B62.TIF out=lsat7_2011_62
r.in.gdal L71107035_03520110413_B10.TIF out=lsat7_2011_10
r.in.gdal L71107035_03520110413_B20.TIF out=lsat7_2011_20
r.in.gdal L71107035_03520110413_B30.TIF out=lsat7_2011_30
r.in.gdal L71107035_03520110413_B40.TIF out=lsat7_2011_40
r.in.gdal L71107035_03520110413_B50.TIF out=lsat7_2011_50
r.in.gdal L72107035_03520110413_B70.TIF out=lsat7_2011_70
r.in.gdal L72107035_03520110413_B80.TIF out=lsat7_2011_80
g.list rast

#
g.region rast=lsat7_2011_61 -p
r.colors lsat7_2011_10 col=grey
r.colors lsat7_2011_20 col=grey
r.colors lsat7_2011_30 col=grey
d.mon wx0
d.erase
d.rgb b=lsat7_2011_10 g=lsat7_2011_20 r=lsat7_2011_30

r.composite blue=lsat7_2011_10 green=lsat7_2011_20 red=lsat7_2011_30 output=lsat7_2011_rgb --overwrite
g.list rast
d.mon wx1
d.erase
d.rast lsat7_2011_rgb

#################### i.cluster ####################
# i.cluster - Generates spectral signatures for land cover types in an image using a clustering algorithm. The resulting signature file is used as input for i.maxlik, to generate an unsupervised image classification.

# store VIZ, NIR, MIR into group/subgroup (leaving out TIR)
i.group group=lsat7_2011 subgroup=lsat7_2011 input=lsat7_2011_10,lsat7_2011_20,lsat7_2011_30,lsat7_2011_40,lsat7_2011_50,lsat7_2011_70

# generate signature file and report
i.cluster group=lsat7_2011 subgroup=lsat7_2011 \
  signaturefile=sig_cluster_lsat2011 \
  classes=10 reportfile=rep_clust_lsat2011.txt --overwrite
  
#################### i.maxlik ####################

# using here the signature file created by i.cluster
i.maxlik group=lsat7_2011 subgroup=lsat7_2011 \
  signaturefile=sig_cluster_lsat2011 \
  output=lsat7_2011_cluster_classes reject=lsat7_2011_cluster_reject --overwrite

# visually check result
d.mon wx1
r.colors --help
r.colors lsat7_2011_cluster_classes col=viridis
d.rast.leg lsat7_2011_cluster_classes
d.rast.leg lsat7_2011_cluster_reject

# see how many pixels were rejected at given levels
r.report lsat7_2011_cluster_reject units=k,p

# optionally, filter out pixels with high level of rejection
# here we remove pixels of at least 90% of rejection probability, i.e. categories 12-16
r.mapcalc "lsat7_2011_cluster_classes_filtered = \
           if(lsat7_2011_cluster_reject <= 5, lsat7_2011_cluster_classes, null())"

d.rast.leg lsat7_2011_cluster_classes_filtered
