# frozen_string_literal: true

class IrisInputRecord < Darlingtonia::InputRecord
  ##
  # @param mapper [#map_fields]
  def initialize(mapper: HashMapper.new)
    super
  end
  ##
  # @return [Hash<Symbol, Object>]
  # mapper.input_fields contains data we need in order to create a geo_work record ( e.g., northlimit, eastlimit, southlimit, westlimit),
  # but they do not map to Hyrax attributes, and so we do not want their values returned from this method

  def attributes
    fields = mapper.fields - mapper.input_fields
    fields.each_with_object({}) do |field, attrs|
      attrs[field] = public_send(field)
    end
  end
end
