# Iris

This project is a Hyrax 1.0.5 application that uses the Samvera Labs geo_works gem to ingest works with spatial geographical data.

<p><a href="https://travis-ci.org/curationexperts/iris"><img src="https://travis-ci.org/curationexperts/iris.svg?branch=master" alt="Build Status"></a>
<a href='https://coveralls.io/github/curationexperts/iris?branch=master'><img src='https://coveralls.io/repos/github/curationexperts/iris/badge.svg?branch=master' alt='Coverage Status' /></a>
</a>

</p>

## Developer Setup

1. Change to your working directory for new development projects
   `cd .`
1. Clone this repo
   `git clone git@github.com:curationexperts/iris.git`
1. Change to the application directory
   `cd iris`
1. `bundle install` under project's current ruby (2.3.4)
1. Start redis
   `redis-server &`
   *note:* use ` &` to start in the background, or run redis in a new terminal
   session

## Integration with a geoblacklight-based app

If you want your fedora objects to be indexed in another solr instance that is used by a geoblacklight app, set the environment variable to point to that solr instance:

`export GEOBLACKLIGHT_SOLR_URL="http://127.0.0.1:8987/solr/development"`

Indexing into the geoblacklight solr happens in a background job, so make sure your environment is configured to run background jobs.

## Integration with GeoServer

See notes in the [README_geoserver.md](README_geoserver.md)

## Install Geo_works dependencies

1. GDAL

- Mac OSX: `brew install gdal`
- Ubuntu: use `sudo apt-get install gdal-bin`


2. Simple Tiles

- Mac OS X: `brew install simple-tiles`

- Linux:

    Install dependencies:

    ```
    ruby
    libgdal-dev
    libcairo2-dev
    libpango1.0-dev
    ```

    Compile:

    ```
    ruby
    $ git clone git@github.com:propublica/simple-tiles.git
    $ cd simple-tiles
    $ ./configure
    $ make && make install
    ```

## Create db

`bundle exec rake db:setup`
`bundle exec rake db:migrate`

## Create default admin set and load workflows

1. Start solr and fedora (in new tabs) `bundle exec solr_wrapper` and `bundle exec fcrepo_wrapper`.

2. Ensure AdminSet dependencies are in place: `bundle exec rake hyrax:workflow:load` and  `bundle exec rake hyrax:default_admin_set:create`

3. Start server `bundle exec rails s`

## Run the app in development mode

* Start redis server
* Start tomcat (if you want to run GeoServer)
* Run fcrepo_wrapper from my iris workspace
* Run solr_wrapper from my iris workspace
* Run solr_wrapper from my aster workspace (if you want to integrate with the geoblacklight app)
* Start sidekiq (if you want to run background jobs)
* Start `rails s`

## Import works using the command-line importer

This application ingests a few multi-file formats, like AIG (for Raster works) and Shapefiles (for Vector works). Our importer expects its binaries to be found in zips, for both Raster and Vector works. Metadata is ingested via `.csv` files. We can create new works with it, but currently, can't update existing works.

Set the following environment variables:

```
export RAILS_HOST='localhost:3000'
export IMPORTER_USER_KEY='batchuser@example.com'

# Where to find your zip files that contain the data
export IMPORTER_FILE_PATH='/Users/valerie/dce/sample_data/ucsb/gis'
```

To import a sample fixture:  
`rake iris:import:import_sample_record`

To import a work from a CSV file:  
`rake iris:import:from_a_csv[/path/to/your/input_file.csv]`

After you run the importer, you need to wait for the background jobs to finish running, and then you should see the new records appear in your Aster app and your GeoServer, assuming that you have your environment configured correctly.
