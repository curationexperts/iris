set :stage, :production
set :rails_env, 'production'
server 'geoworks-sandbox.library.ucsb.edu', user: 'adrl', roles: [:web, :app]
