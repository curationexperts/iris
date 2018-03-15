# UCSB GeoWorks

This project is a Hyrax 1.0.5 application that uses the Samvera Labs geo_works gem to ingest works with spatial geographical data.

<p><a href="https://travis-ci.org/curationexperts/ucsb-geo_works"><img src="https://travis-ci.org/curationexperts/ucsb-geo_works.svg?branch=master" alt="Build Status"></a>
<a href='https://coveralls.io/github/curationexperts/ucsb-geo_works'><img src='https://coveralls.io/repos/github/curationexperts/ucsb-geo_works/badge.svg' alt='Coverage Status' /></a>

</p>

## Developer Setup

1. Change to your working directory for new development projects
   `cd .`
1. Clone this repo
   `git clone https://github.com/curationexperts/ucsb-geo_works.git`
1. Change to the application directory
   `cd ucsb-geo_works`
1. `bundle install` under project's current ruby (2.3.4)
1. Start redis
   `redis-server &`
   *note:* use ` &` to start in the background, or run redis in a new terminal
   session

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
