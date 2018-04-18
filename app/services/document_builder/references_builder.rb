module DocumentBuilder
  class ReferencesBuilder < GeoWorks::Discovery::DocumentBuilder::ReferencesBuilder
    delegate :request, to: :geo_concern
    delegate :host, to: :request
    delegate :protocol, to: :request

    # The document builder in geo_works assumes that
    # the download link for the work should be the
    # first FileSet that's attached to the work, since
    # the first one would normally be the
    # representative file for the work.
    # We want the download link to be the zip file,
    # which is not necessarily the first FileSet, so
    # we override this method from geo_works to
    # return the download link for the zip file (if
    # there is a zip file attached to the work).
    def download
      file_set = geo_concern.file_set_presenters.select { |presenter| File.extname(presenter.label || '') == '.zip' }.first
      if file_set
        Hyrax::Engine.routes.url_helpers.download_url(file_set, host: host, protocol: protocol)
      else
        super
      end
    end
  end
end
