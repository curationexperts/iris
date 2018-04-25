# frozen_string_literal: true

module GeoServer
  class Coverage < RGeoServer::Coverage

    # This method overrides the method from rgeoserver
    # to remove the nativeName from the XML.
    # This is the problem we had:
    # https://github.com/curationexperts/iris/issues/50
    # and here:
    # https://gis.stackexchange.com/questions/133115/geoserver-rest-api-bug-the-specified-coveragename-is-not-supported
    def message
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.coverage {
          xml.name @name
          xml.title @title if title_changed? || new?
          xml.abstract @abstract if abstract_changed? || new?
          xml.enabled @enabled
          xml.metadataLinks {
            @metadata_links.each do |m|
              raise ArgumentError, "Malformed metadata_links" unless m.is_a? Hash
              xml.metadataLink {
                xml.type_ to_mimetype(m['metadataType'])
                xml.metadataType m['metadataType']
                xml.content m['content']
              }
            end
          } unless @metadata_links.empty?
          xml.keywords {
            @keywords.each do |k|
              xml.keyword RGeoServer::Metadata::to_keyword(k)
            end
          } if @keywords and new? or keywords_changed?

        }
      end
      @message = builder.doc.to_xml
    end

  end
end
