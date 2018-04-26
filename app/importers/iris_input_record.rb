# frozen_string_literal: true

class IrisInputRecord < Darlingtonia::InputRecord
  ##
  # @param mapper [#map_fields]
  def initialize(mapper: HashMapper.new)
    super
  end

  delegate :geo_mime_type, to: :mapper

  # Files we want to attach to this work include any
  # files that the mapper extracted from the zip, plus
  # the zip file itself.
  def files
    ext_files = mapper.extracted_files || []
    ext_files + [mapper.zip.name.to_s]
  end

  ##
  # @return [Hash<Symbol, Object>]
  # mapper.input_fields contains data we need in order to create a geo_work record ( e.g., northlimit, eastlimit, southlimit, westlimit),
  # but they do not map to Hyrax attributes, and so we do not want their values returned from this method
  def attributes
    fields = mapper.fields - mapper.input_fields
    attrs = fields.each_with_object({}) do |field, attrs_hash|
      attrs_hash[field] = public_send(field)
    end
    attrs[:visibility] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    attrs
  end
end
