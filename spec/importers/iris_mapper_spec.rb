# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IrisMapper do
  subject(:mapper) { described_class.new }
  let(:input_record) { Darlingtonia::InputRecord.from(metadata: image_work_metadata, mapper: described_class.new) }
  let(:image_work_metadata) do
    { "title" => "Great",
      "creator" => "Stephen Hawking",
      "keyword" => "physics",
      "rights" => "http://creativecommons.org/publicdomain/zero/1.0/",
      "spatial" => "Alaska",
      "temporal" => "2018",
      "provenance" => "UCSB",
      "resource_type" => "ImageWork" }
  end
  let(:hyrax_metadata) do
    { title: ["Great"],
      creator: ["Stephen Hawking"],
      keyword: ["physics"],
      rights: ["http://creativecommons.org/publicdomain/zero/1.0/"],
      resource_type: ["ImageWork"],
      spatial: ["Alaska"],
      temporal: ["2018"],
      provenance: "UCSB",
      visibility: nil,
      representative_file: nil,
      shapefiles: nil,
      geo_mime_type: nil }
  end

  it "maps the required title field" do
    mapper.metadata = { "title" => "Research" }
    expect(mapper.map_field(:title)).to eq(["Research"])
  end

  it "maps the required creator field" do
    mapper.metadata = { "creator" => "Stephen Hawking" }
    expect(mapper.map_field(:creator)).to eq(["Stephen Hawking"])
  end

  it "maps the required keyword field" do
    mapper.metadata = { "keyword" => "physics" }
    expect(mapper.map_field(:keyword)).to eq(["physics"])
  end

  it "maps the required rights field" do
    mapper.metadata = { "rights" => "http://creativecommons.org/publicdomain/zero/1.0/" }
    expect(mapper.map_field(:rights)).to eq(["http://creativecommons.org/publicdomain/zero/1.0/"])
  end

  it "maps the required resource_type field" do
    mapper.metadata = { "resource_type" => "ImageWork" }
    expect(mapper.map_field(:resource_type)).to eq(["ImageWork"])
  end

  it "maps the visibility field" do
    mapper.metadata = { "visibility" => "open" }
    expect(mapper.visibility).to eq("open")
  end

  it "maps the provenance field" do
    mapper.metadata = { "provenance" => "UCSB" }
    expect(mapper.provenance).to eq("UCSB")
  end

  it "maps the spatial field" do
    mapper.metadata = { "spatial" => "Alaska" }
    expect(mapper.spatial).to eq(["Alaska"])
  end

  it "maps the temporal field" do
    mapper.metadata = { "temporal" => "2018" }
    expect(mapper.temporal).to eq(["2018"])
  end

  it "provides all the necessary fields" do
    mapper.metadata = image_work_metadata

    expect(input_record.attributes).to eql hyrax_metadata
  end

  context "with an attached file" do
    let(:image_work_metadata) do
      { "title" => "Great",
        "file_name" => "geo_tif.tif",
        "geo_mime_type" => "image/tiff; gdal-format=GTiff" }
    end

    it "maps the geo_mime_type" do
      mapper.metadata = { "geo_mime_type" => "image/tiff; gdal-format=GTiff" }
      expect(mapper.geo_mime_type).to eq("image/tiff; gdal-format=GTiff")
    end

    it "maps the file_name field" do
      mapper.metadata = { "file_name" => "geo_tif.tif" }
      expect(mapper.representative_file).to eq("geo_tif.tif")
    end
  end

  context "with an attached shapefile zip" do
    # we replace single-quotes, required for oob csv parsing, with double-quotes, required by geo_works. See iris_mapper.rb for more detail.
    it "maps the geo_mime_type" do
      mapper.metadata = { "geo_mime_type" => "application/zip; ogr-format='ESRI Shapefile'" }
      expect(mapper.geo_mime_type).to eq('application/zip; ogr-format="ESRI Shapefile"')
    end
  end
end
