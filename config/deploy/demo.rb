set :stage, :demo
set :rails_env, 'production'
server 'iris-demo.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
