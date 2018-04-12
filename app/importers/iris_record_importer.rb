# frozen_string_literal: true

##
# A `Darlingtonia::RecordImporter` that processes
# files and passes new works through the Actor
# Stack for creation.
class IrisRecordImporter < Darlingtonia::RecordImporter
  ##
  # @!attribute [rw] creator
  #   @return [User]
  # @!attribute [rw] file_path
  # @return [String]
  attr_accessor :creator, :file_path

  ##
  # @param file_path [String] the directory that contains the file(s) that we want to attach to the new work record.
  # @param creator   [User]
  def initialize(**opts)
    self.creator   = opts.delete(:creator)   || raise(ArgumentError)
    self.file_path = opts.delete(:file_path) || raise(ArgumentError)
    super
  end

  private

    # TODO: validate for resource_type
    def create_for(record:)
      info_stream << 'Creating record: ' \
                     "#{record.respond_to?(:title) ? record.title : record}."

      work_type = record.resource_type.first.classify.constantize
      attributes = record.attributes
      binary_file = attributes.delete(:representative_file)
      shape_files = attributes.delete(:shapefiles)

      geo_mime_type = attributes.delete(:geo_mime_type)
      created = work_type.create(attributes)

      # TODO: find out from UCSB if valid record data requires a binary file, if so, these checks for nil will not be necessary
      attach_files(work: created, file_names: [File.join(file_path, binary_file)], geo_mime_type: geo_mime_type) unless binary_file.nil?
      attach_files(work: created, file_names: [File.join(file_path, shape_files)], geo_mime_type: geo_mime_type) unless shape_files.nil?

      trigger_create_events(created)

      info_stream << "Record created at: #{created.id}"
    end

    # The geo_works gem requires that the work must
    # exist before you can attach files.
    #
    # @param work [RasterWork, VectorWork, ImageWork] The work to attach files to.
    # @param file_names [Array<String>] the list of file names (including paths) for the files we want to attach to the work.
    # @param geo_mime_type [String] tells geo_works how to process the binaries.
    def attach_files(work:, file_names:, geo_mime_type:)
      # Process contents of zip files first
      process_zip_files(work, file_names, geo_mime_type)

      file_names.each do |file_name|
        ::FileSet.new do |file_set|
          user = User.batch_user
          file_set["geo_mime_type"] = geo_mime_type_for_file(geo_mime_type, file_name)
          actor = Hyrax::Actors::FileSetActor.new(file_set, user)
          actor.create_metadata(visibility: work.visibility)
          file = ::ImportFile.new(file_name)
          actor.create_content(file)
          actor.attach_file_to_work(work, visibility: work.visibility)
        end
      end
    end

    # Since we are attaching other files to the work
    # besides just the primary representative file,
    # the geo_mime_type of the supplementary files
    # might be different from the representative
    # file's geo_mime_type.
    #
    # For example, if we attach a geo-tiff as the
    # representative file, but also attach a zip file
    # for users to download, we set the zip file's
    # geo_mime_type to nil so the geo_works gem
    # doesn't try to process it as a raster file.
    #
    # @param geo_mime_type [String] the geo_mime_type of the representative file for this work
    # @param file_name [String] the name of the file that we want to find the geo_mime_type for
    # @return [String] the geo_mime_type for the file that we want to attach to the work
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

    # @param work [RasterWork, VectorWork, ImageWork] The work to attach files to.
    # @param file_names [Array<String>] the list of file names (including paths) for the files we want to attach to the work.
    # @param geo_mime_type [String] The geo mime type of the primary file for the work (It should be one of the geo_mime_type's that the geo_works gem allows).
    #
    def process_zip_files(work, file_names, geo_mime_type)
      return unless need_to_extract_files?(geo_mime_type)

      zip_files = file_names.select { |file_name| File.extname(file_name) == '.zip' }

      zip_files.each do |file_name|
        extract_files_from_zip(work, file_name, geo_mime_type)
      end
    end

    # Some files (such as shapefiles) don't need to
    # be unzipped because the geo_works gem expects
    # the zip file to be the primary file.
    #
    # For geo_mime_types where geo_works doesn't
    # expect a zip file, we need to extract the
    # primary file from the zip and attach it as the
    # representative file for the work.
    #
    # For now we'll only unzip for geo-tiff files.
    # Other types will be future work.
    def need_to_extract_files?(geo_mime_type)
      geo_mime_type.match?(/gdal-format=GTiff/)
    end

    # If we have a zipped geo-tiff file, then unzip
    # the file so we can directly attach the *.tif
    # file to the work (as geo_works gem expects).
    def extract_files_from_zip(work, file_name, geo_mime_type)
      temp_dir = Dir::Tmpname.create(['iris-'], Hydra::Derivatives.temp_file_base) {}
      FileUtils.mkdir_p(temp_dir)
      Zip::File.open(file_name) do |zip_file|
        tif_files = zip_file.glob(File.join('**', '*.tif'))
        tif_files.each do |tif|
          next unless tif.file?
          dest_file = File.join(temp_dir, File.basename(tif.name))
          tif.extract(dest_file)
          attach_files(work: work, file_names: [dest_file], geo_mime_type: geo_mime_type)
        end
      end
    end

    # After the new work is created, trigger
    # 'record_created' events so that the
    # GeoBlacklight app and the GeoServer instance
    # will be updated with the new record.
    #
    # @param work [RasterWork, VectorWork, ImageWork] The work that was created by this importer.
    #
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
end
