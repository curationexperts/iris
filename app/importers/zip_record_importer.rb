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

    begin
      trigger_create_events(created)
    rescue ArgumentError => e
      error_stream << e.message
    end

    info_stream << "Record created at: #{created.id}\n"
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
end
