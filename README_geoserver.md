# Integrate your Iris app with GeoServer

## Install GeoServer

* Install Tomcat: 
  - Mac OSX: `brew install tomcat`

* Download the 'Web Archive' for the latest release of GeoServer: [GeoServer Releases](http://geoserver.org/release/stable/)

* Unzip the package, and copy the WAR file into the 'webapps' directory for Tomcat.
  - If you installed with homebrew, it's probably here: `/usr/local/Cellar/tomcat/[version]/libexec/webapps/`
* Start Tomcat: `catalina run`

* Use browser to view GeoServer console:
http://localhost:8080/geoserver

* Log in with default user/password: `admin/geoserver`

* You should see some sample data already loaded.  You can delete the sample data from the console if you wish.

* Create a new workspace called `public` (assuming you are using geo_works defaults), with a URL `http::/public`.  Check the `Enabled` box, and check the boxes for the 4 services: WMTS, WCSWCS, WFSWFS, WMSWMS.  Then hit 'Save'.

## To manually upload a file in the GeoServer console

* Stores -> Add new Store -> ShapeFile

* Click 'Browse' next to 'Shapefile location', and select the file from the Belize vegetation files:
gford-20140000-010015_belvegr.shp

* Once you save that file, you should see it in the 'New Layer' list.  Click 'Publish' next to that file.

* Scroll down to Bounding Boxes -> click 'Compute from data'
* 'Compute from native bounds'
* Save

* Layer Preview -> Open Layers
* Then you can view the map

## Iris Setup

* To integrate your Iris app with GeoServer, set these environment variables:

```
export PUBLIC_GEOSERVER_URL="http://localhost:8080/geoserver/rest"

# Needs to match the Hyrax derivatives path, which is under tmp by default
export PUBLIC_GEOSERVER_DERIVATIVES_PATH="/[Rails root dir]/tmp/derivatives"
```

* See the [geoserver.yml in geo_works](https://github.com/samvera-labs/geo_works/blob/master/config/geoserver.yml) for more environment variables you might want to set if you aren't using the default values.  For example, in production, you'll need to disable the default login user/password for GeoServer.

* Now you should be able to run the Iris importer (see the main README for more info).  After the importer finishes and all the background jobs finish, the Iris work records should appear in GeoServer.  If you don't see the records on the GeoServer `Stores` page, you may have to reload the page.  It doesn't update live, and I've noticed that the record counts aren't always correct, but if you click into the `Stores` page, you'll see the new records.

* To show your current geoserver config: `GeoWorks::GeoServer.config`

