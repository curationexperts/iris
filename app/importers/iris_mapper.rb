# frozen_string_literal: true
class IrisMapper < Darlingtonia::HashMapper
  def fields
    [:creator, :title, :keyword, :rights, :resource_type, :visibility, :representative_file, :shapefiles, :geo_mime_type, :spatial, :temporal, :provenance]
  end

  def visibility
    metadata['visibility']
  end

  def representative_file
    metadata['file_name']
  end

  def shapefiles
    metadata['shape_file']
  end

  def provenance
    metadata['provenance']
  end

  def spatial
    [metadata['spatial']]
  end

  def temporal
    [metadata['temporal']]
  end
  # we need to send the geo-derivatives class double-quoted strings, but csv input works out of the box with single quotes. this method replaces singles in the csv with doubles.
  # TODO: we might want to use a validator to enforce single quotes in the csvs instead.

  def geo_mime_type
    return if metadata['geo_mime_type'].nil?
    metadata['geo_mime_type'].tr("'", "\"")
  end
end
