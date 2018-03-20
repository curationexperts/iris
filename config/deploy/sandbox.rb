set :stage, :localhost
set :rails_env, 'production'
server 'iris-sandbox.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
