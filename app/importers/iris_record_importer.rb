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
      created = work_type.create(record.attributes)

      info_stream << "Record created at: #{created.id}"
    end
end
