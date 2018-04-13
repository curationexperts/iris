# The document builder services in the geo_works
# engine depend on the controller's request object.
# But the importer doesn't have access to a request
# or a controller, so this class acts as a shim to
# provide the methods that geo_works expects to be
# able to call.
#
# Reference this class in the geo_works gem:
# app/services/geo_works/discovery/document_builder/document_path.rb

class RequestShim
  def host_with_port
    ENV['RAILS_HOST']
  end

  def host
    host_with_port
  end

  def protocol
    Rails.application.config.force_ssl ? 'https://' : 'http://'
  end
end
