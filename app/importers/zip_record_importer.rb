# frozen_string_literal: true

##
# A `Darlingtonia::RecordImporter`
class ZipRecordImporter < Darlingtonia::RecordImporter
  ##
  # @see Darlingtonia::RecordImporter#create_for
  def create_for(record:)
    info_stream << 'Creating record: ' \
                   "#{record.mapper.zip.name}; " \
                   "#{record.respond_to?(:title) ? record.title : record}.\n"

    work_type  = record.resource_type.first.classify.constantize
    attributes = record.attributes
    created    = work_type.create(attributes)
    attach_files(created, record.files, record.geo_mime_type)

    begin
      trigger_create_events(created)
    rescue ArgumentError => e
      error_stream << e.message
    end

    info_stream << "Record created at: #{created.id}\n"
  end

  # The geo_works gem requires that the work must
  # exist before you can attach files.
  #
  # @param work [RasterWork, VectorWork, ImageWork] The work to attach files to.
  # @param file_paths [Array<String>] the list of full file paths for the files we want to attach to the work.
  # @param geo_mime_type [String] tells geo_works how to process the binaries.
  def attach_files(work, file_paths, geo_mime_type)
    file_paths.each do |file_path|
      ::FileSet.new do |file_set|
        user = User.batch_user
        file_set['geo_mime_type'] = geo_mime_type_for_file(geo_mime_type, file_path)
        actor = Hyrax::Actors::FileSetActor.new(file_set, user)
        actor.create_metadata(visibility: work.visibility)
        file = ::ImportFile.new(file_path)
        actor.create_content(file)
        actor.attach_file_to_work(work)
      end
    end
  end

  def trigger_create_events(work)
    # The geo_works event code is coupled to the
    # controller/presenter logic, so we need to
    # create a presenter to pass in.
    solr_document = SolrDocument.new(work.to_solr)
    current_ability = ::Ability.new(nil)
    request = RequestShim.new
    presenter = presenter_class(work).new(solr_document, current_ability, request)

    GeoWorks::EventsGenerator.new.record_created(presenter)
  end

  # @param work [RasterWork, VectorWork, ImageWork] The work record that was created by this importer.
  def presenter_class(record)
    case record
    when ::VectorWork
      GeoWorks::VectorWorkShowPresenter
    when ::RasterWork
      GeoWorks::RasterWorkShowPresenter
    when ::ImageWork
      GeoWorks::ImageWorkShowPresenter
    else
      GeoWorks::GeoWorksShowPresenter
    end
  end

  # Since we are attaching other files to the work
  # besides just the primary representative file,
  # the geo_mime_type of the supplementary files
  # might be different from the representative
  # file's geo_mime_type.
  #
  # @param geo_mime_type [String] the geo_mime_type of the representative file for this work
  # @param file_name [String] the name of the file that we want to find the geo_mime_type for
  #
  # @return [String] the geo_mime_type that should be used for this file
  def geo_mime_type_for_file(geo_mime_type, file_name)
    return geo_mime_type if expects_zip_files.include?(geo_mime_type)
    return nil if File.extname(file_name) == '.zip'
    geo_mime_type
  end

  # For these geo-mime-types, the geo_works gem
  # expects the work's representative file to be a
  # zip file.
  def expects_zip_files
    ['application/octet-stream; gdal-format=AIG',
     'application/zip; ogr-format="ESRI Shapefile"']
  end
end
