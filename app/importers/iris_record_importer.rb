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
  # @param file_path [String]
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
      created = work_type.create(attributes)
      # TODO: find out from UCSB if valid record data requires a binary file, if so, this check for nil will not be necessary
      attach_files(work: created, binary_file_name: binary_file) unless binary_file.nil?

      info_stream << "Record created at: #{created.id}"
    end

    # The geo_works gem requires that the work must
    # exist before you can attach files.
    #
    # @param work [RasterWork, VectorWork] The work to attach files to.
    def attach_files(work:, binary_file_name:)
      # TODO: Find out from UCSB if it's just file names, or if there will be other info about the files
      file_names = [binary_file_name]
      file_names.each do |file_name|
        ::FileSet.new do |file_set|
          user = User.batch_user
          actor = Hyrax::Actors::FileSetActor.new(file_set, user)
          actor.create_metadata(visibility: work.visibility)

          # TODO: Find out from UCSB - instead of assuming the file is located at the file_path, we probably need to be able to pass in a root directory where the data files are located.

          file = ::ImportFile.new(File.join(file_path, file_name))
          actor.create_content(file)
          actor.attach_file_to_work(work, visibility: work.visibility)
        end
      end
    end
end
