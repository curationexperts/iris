# frozen_string_literal: true
require 'rails_helper'
require 'csv'

RSpec.describe Importer do
  subject(:importer) { described_class.new(parser: parser) }
  let(:file) { File.open('spec/fixtures/example.csv') }
  let(:parser) { IrisCsvParser.new(file: file) }

  it "can create an Importer" do
    expect(importer).to be_instance_of described_class
  end

  it "inherits from the Darlingtonia Importer" do
    expect(described_class).to be < Darlingtonia::Importer
  end

  it "uses the IrisCsvParser" do
    expect(importer.parser.class).to eq IrisCsvParser
  end

  it "creates an ImageWork from a one-row csv" do
    expect { importer.import }.to change { ImageWork.count }.by 1
    expect(ImageWork.count).to eq 1
    image = ImageWork.first

    expect(image.visibility).to eq "open"
  end

  context "a CSV without 'visibility' field" do
    let(:file) { File.open(File.join(fixture_path, "example_with_no_visibility.csv")) }

    it "creates a work with 'restricted' visibility" do
      expect { importer.import }.to change { ImageWork.count }.by 1
      expect(ImageWork.count).to eq 1
      image = ImageWork.first

      expect(image.visibility).to eq "restricted"
    end
  end
  # TODO: test shapefiles
  context 'creates a RasterWork and then attaches a geo tif file' do
    let(:file) { File.open(File.join(fixture_path, "raster_example.csv")) }
    let(:binary_title) do
      data = CSV.read(File.join(fixture_path, "raster_example.csv"), headers: true)
      data['file_name'].first
    end

    it 'attaches file as a FileSet and sets its representative title to file_name', :perform_enqueued do
      ActiveJob::Base.queue_adapter.filter = [IngestFileJob]

      importer.import
      raster_work = RasterWork.where(title: 'Great Rasters')

      expect(FileSet.find(raster_work.first.representative_id).title.first).to eql(binary_title)
    end

    it "creates a thumbnail", :perform_enqueued do
      ActiveJob::Base.queue_adapter.filter = [IngestFileJob]

      importer.import
      raster_work = RasterWork.where(title: 'Great Rasters')

      expect(FileSet.find(raster_work.first.representative_id).thumbnail_id).not_to be_empty
    end

    it "adds file_set information to the work's index", :perform_enqueued do
      ActiveJob::Base.queue_adapter.filter = [IngestFileJob]

      importer.import
      raster_work = RasterWork.where(title: 'Great Rasters')

      expect(raster_work.first.to_solr["file_set_ids_ssim"]).not_to be_empty
    end
  end
end
