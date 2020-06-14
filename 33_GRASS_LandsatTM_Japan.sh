#!/bin/sh
# GRASS GIS script for processing and visualizing Landsat TM image. Japan, Tokyo Area.
# metadata in GDAL (run by GMT)
gdalinfo p107r035_7dk20010924_z54_61.tif
# rotate to north up, write GeoTIFF, enforce 28.5m x 28.5m res.
gdalwarp -tr 28.5 28.5 p107r035_7dk20010924_z54_61.tif p107r035_7dk20010924_z54_61_rot.tif
gdalwarp -tr 28.5 28.5 p107r035_7dk20010924_z54_62.tif p107r035_7dk20010924_z54_62_rot.tif
gdalwarp -tr 28.5 28.5 p107r035_7dp20010924_z54_80.tif p107r035_7dp20010924_z54_80_rot.tif
gdalwarp -tr 28.5 28.5 p107r035_7dt20010924_z54_10.tif p107r035_7dt20010924_z54_10_rot.tif
gdalwarp -tr 28.5 28.5 p107r035_7dt20010924_z54_20.tif p107r035_7dt20010924_z54_20_rot.tif
gdalwarp -tr 28.5 28.5 p107r035_7dt20010924_z54_30.tif p107r035_7dt20010924_z54_30_rot.tif
gdalwarp -tr 28.5 28.5 p107r035_7dt20010924_z54_40.tif p107r035_7dt20010924_z54_40_rot.tif
gdalwarp -tr 28.5 28.5 p107r035_7dt20010924_z54_50.tif p107r035_7dt20010924_z54_50_rot.tif
gdalwarp -tr 28.5 28.5 p107r035_7dt20010924_z54_70.tif p107r035_7dt20010924_z54_70_rot.tif
gdalinfo p107r035_7dk20010924_z54_61_rot.tif

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
