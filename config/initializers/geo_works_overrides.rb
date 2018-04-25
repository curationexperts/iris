# Use our own document builder classes instead of the ones from geo_works.
# See the class file for the ReferencesBuilder class for more details.

GeoWorks::Discovery::DocumentBuilder.services = [
  GeoWorks::Discovery::DocumentBuilder::BasicMetadataBuilder,
  GeoWorks::Discovery::DocumentBuilder::SpatialBuilder,
  GeoWorks::Discovery::DocumentBuilder::DateBuilder,
  DocumentBuilder::ReferencesBuilder, # override geo_works
  GeoWorks::Discovery::DocumentBuilder::LayerInfoBuilder,
  GeoWorks::Discovery::DocumentBuilder::SlugBuilder
]

# Use our own Coverage model for talking to GeoServer.
GeoWorks::Delivery::Geoserver.coverage_class = ::GeoServer::Coverage
