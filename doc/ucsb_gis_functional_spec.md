# UCSB GIS Functional Spec

1. There are two code bases, iris and aster

## Aster / GeoBlacklight / Spatial Discovery
1. It provides a GeoBlacklight based discovery interface
  1. It allows objects to be discovered via spatial search
  1. Objects can be discovered via metadata search
  1. Objects can be browsed via metadata facets
1. It displays shapefile (vector) and GeoTiff (raster) works
1. It allows for downloading files:
  1. of the original .zip file with all associated data and metadata files
  1. of the re-projected shape file
  1. of re-formatting that can be done by GeoServer, e.g., kml, geojson, png, etc. 
1. It can display geospatial data on a javascript map
  1. The map provides pan and zoom functions
  1. The map displays on a base map
  1. The map also displays associated data when applicable
1. It uses the out-of-box metadata mappings for ISO provided by GeoWorks


## Iris / GeoWorks / Ingest
1. It ingests shapefiles and geotiffs (and associated metadata)
1. It has a command line importer
1. The command line importer expects to receive a directory of .zip files
  1. Each zip file should contain an ISO-19139 metadata file
  1. Each zip file should contain either a shapefile or a GeoTiff binary object
1. It assigns each ingested .zip file a unique identifier, which can be used to find that object on multiple systems
1. It uses the out-of-box metadata mappings to extract metdata from ISO and map it to a Fedora object 
1. It creates a thumbnail image of the work
1. It creates a re-projected derivative of the spatial object
1. It makes the re-projected derivative available via OGC webservices (in the form of GeoServer)

## System concerns
1. It has an automated deployment job
1. It has an automated test suite 
1. It has configuration management scripts available for Ubuntu 16.04 (RedHat pending)
