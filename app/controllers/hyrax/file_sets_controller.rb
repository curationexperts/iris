module Hyrax
  class FileSetsController < ApplicationController
    include Hyrax::FileSetsControllerBehavior
    include GeoConcerns::FileSetsControllerBehavior
    include GeoConcerns::EventsBehavior

    include GeoWorks::FileSetsControllerBehavior
    include GeoWorks::EventsBehavior
  end
end
