#!/bin/sh
# GRASS GIS script for processing and visualizing Landsat TM image. Japan, Tokyo Area.
gdalinfo L71107035_03520061109_B61.tif
# import the image subset and display the raster map
r.in.gdal L71107035_03520061109_B61.tif out=lsat7_2006_61
r.in.gdal L72107035_03520061109_B62.tif out=lsat7_2006_62
r.in.gdal L71107035_03520061109_B10.tif out=lsat7_2006_10
r.in.gdal L71107035_03520061109_B20.tif out=lsat7_2006_20
r.in.gdal L71107035_03520061109_B30.tif out=lsat7_2006_30
r.in.gdal L71107035_03520061109_B40.tif out=lsat7_2006_40
r.in.gdal L71107035_03520061109_B50.tif out=lsat7_2006_50
r.in.gdal L72107035_03520061109_B70.tif out=lsat7_2006_70
r.in.gdal L72107035_03520061109_B80.tif out=lsat7_2006_80
g.list rast

#
g.region rast=lsat7_2006_61 -p
r.colors lsat7_2006_10 col=grey
r.colors lsat7_2006_20 col=grey
r.colors lsat7_2006_30 col=grey
d.mon wx0
d.erase
d.rgb b=lsat7_2006_10 g=lsat7_2006_50 r=lsat7_2006_30

r.composite blue=lsat7_2006_10 green=lsat7_2006_50 red=lsat7_2006_30 output=lsat7_2006_rgb
g.list rast
d.mon wx1
d.erase
d.rast lsat7_2006_rgb

#################### i.cluster ####################
# i.cluster - Generates spectral signatures for land cover types in an image using a clustering algorithm. The resulting signature file is used as input for i.maxlik, to generate an unsupervised image classification.

# store VIZ, NIR, MIR into group/subgroup (leaving out TIR)
i.group group=lsat7_2006 subgroup=lsat7_2006 input=lsat7_2006_10,lsat7_2006_20,lsat7_2006_30,lsat7_2006_40,lsat7_2006_50,lsat7_2006_70

# generate signature file and report
i.cluster group=lsat7_2006 subgroup=lsat7_2006 \
  signaturefile=sig_cluster_lsat2006 \
  classes=10 reportfile=rep_clust_lsat2006.txt
  
#################### i.maxlik ####################

# using here the signature file created by i.cluster
i.maxlik group=lsat7_2006 subgroup=lsat7_2006 \
  signaturefile=sig_cluster_lsat2006 \
  output=lsat7_2006_cluster_classes reject=lsat7_2006_cluster_reject --overwrite

# visually check result
d.mon wx0
r.colors --help
r.colors lsat7_2006_cluster_classes col=viridis
d.rast.leg lsat7_2006_cluster_classes
d.rast.leg lsat7_2006_cluster_reject

# see how many pixels were rejected at given levels
r.report lsat7_2006_cluster_reject units=k,p

# optionally, filter out pixels with high level of rejection
# here we remove pixels of at least 90% of rejection probability, i.e. categories 12-16
r.mapcalc "lsat7_2006_cluster_classes_filtered = \
           if(lsat7_2006_cluster_reject <= 12, lsat7_2006_cluster_classes, null())"
