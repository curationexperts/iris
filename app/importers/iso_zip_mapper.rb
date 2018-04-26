# frozen_string_literal: true
class IsoZipMapper < Darlingtonia::MetadataMapper
  def fields
    [:title, :creator, :iso, :resource_type, :zip, :coverage, :provenance, :temporal, :spatial, :keyword]
  end

  def input_fields
    [:iso, :zip, :northlimit, :eastlimit, :southlimit, :westlimit]
  end

  NS = {
    'xmlns:gmd' => 'http://www.isotc211.org/2005/gmd',
    'xmlns:gco' => 'http://www.isotc211.org/2005/gco',
    'xmlns:gml' => "http://www.opengis.net/gml"
  }.freeze

  def iso
    @iso_xml ||=
      begin
        iso_entry.extract(File.join(tmp_dir, iso_entry_name))
        Nokogiri::XML(iso_entry.get_input_stream.read)
      end
  end

  def tif
    @tif ||=
      zip.glob('**/*.tif').map do |file|
        dest_file = File.join(tmp_dir, File.basename(file.name))
        file.extract(dest_file)
        dest_file
      end
  end

  # TODO: Add the other types as needed.
  def geo_mime_type
    if shapefile?
      'application/zip; ogr-format="ESRI Shapefile"'
    elsif tif?
      'image/tiff; gdal-format=GTiff'
    elsif binary_grid?
      'application/octet-stream; gdal-format=AIG'
    end
  end

  # TODO: Add the other types as needed.
  def resource_type
    if shapefile?
      ['VectorWork']
    elsif tif? || binary_grid?
      ['RasterWork']
    end
  end

  # For some types of records, we want to extract some
  # of the files from the zip and attach those files
  # directly to the work record (because geo_works
  # gem expects the representative file for the work
  # to be the main raster or vector file, not the zip).
  #
  # @return [Array<String>] the list of full paths to the extracted files that we want to attach.
  def extracted_files
    return @extracted_files if @extracted_files
    # TODO: Add other types of extracted files
    @extracted_files = tif
  end

  def title
    iso.xpath('//xmlns:citation/xmlns:CI_Citation/xmlns:title/gco:CharacterString')
       .map(&:text)
  end

  def creator
    creator = ''
    iso.xpath('//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue=\'originator\']', NS).each do |node|
      creator = begin
        [node.at_xpath('ancestor-or-self::*/gmd:individualName', NS).text.strip]
      rescue
        [node.at_xpath('ancestor-or-self::*/gmd:organisationName', NS).text.strip]
      end
    end
    creator
  end

  def provenance
    'University of California, Santa Barbara'
  end

  def coverage
    northlimit = iso.xpath('//xmlns:EX_GeographicBoundingBox//xmlns:northBoundLatitude').text.strip
    eastlimit = iso.xpath('//xmlns:EX_GeographicBoundingBox//xmlns:eastBoundLongitude').text.strip
    southlimit = iso.xpath('//xmlns:EX_GeographicBoundingBox//xmlns:southBoundLatitude').text.strip
    westlimit = iso.xpath('//xmlns:EX_GeographicBoundingBox//xmlns:westBoundLongitude').text.strip

    GeoWorks::Coverage.new(northlimit, eastlimit, southlimit, westlimit).to_s
  end

  def spatial
    place = ''
    iso.xpath("//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue='place']", NS).each do |node|
      place = begin
        [node.at_xpath('ancestor-or-self::*/gmd:keyword', NS).text.strip]
      rescue
        [node.at_xpath('ancestor-or-self::*/gmd:keyword', NS).text.strip]
      end
    end
    place
  end

  def temporal
    return nil if iso.xpath('//gml:TimeInstant').empty? && iso.xpath('//gml:TimePeriod').empty?

    if iso.xpath('//gml:TimeInstant').any?
      temporal = iso.xpath("//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition", NS).text
    else
      start = iso.xpath("//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition", NS).text
      finish = iso.xpath("//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition", NS).text
      temporal = start + " - " + finish
    end
    [temporal]
  end

  def keyword
    theme = ''
    iso.xpath("//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue='theme']", NS).each do |node|
      theme = begin
        [node.at_xpath('ancestor-or-self::*/gmd:keyword', NS).text.strip]
      rescue
        [node.at_xpath('ancestor-or-self::*/gmd:keyword', NS).text.strip]
      end
    end
    theme
  end

  def zip
    metadata || raise('Trying to access zip before set; use `#metadata=`.')
  end

  private

    def iso_entry_name
      zip.name.split.last.sub('.zip', '').to_s +
        '-iso19139.xml'
    end

    def iso_entry
      zip.glob(File.join('**', iso_entry_name)).first
    end

    def tmp_dir
      directory = Dir::Tmpname.create(['iris-'], Hydra::Derivatives.temp_file_base) {}

      FileUtils.mkdir_p(directory)
      directory
    end

    def shapefile?
      zip.glob('**/*.shp').present?
    end

    def tif?
      zip.glob('**/*.tif').present?
    end

    def binary_grid?
      zip.glob('**/*.adf').present?
    end
end
