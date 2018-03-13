class Hyrax::VectorWorksController < ApplicationController
  include Hyrax::WorksControllerBehavior
  include Hyrax::ParentContainer
  include GeoWorks::VectorWorksControllerBehavior
  include GeoWorks::GeoblacklightControllerBehavior
  include GeoWorks::EventsBehavior
  self.curation_concern_type = VectorWork
end
