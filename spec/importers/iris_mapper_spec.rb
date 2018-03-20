# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IrisMapper do
  subject(:mapper) { described_class.new }
  let(:input_record) { Darlingtonia::InputRecord.from(metadata: image_work_metadata, mapper: described_class.new) }
  let(:image_work_metadata) do
    { "title" => "Great",
      "creator" => "Stephen Hawking",
      "keyword" => "physics",
      "rights" => "Yes",
      "resource_type" => "ImageWork" }
  end
  let(:hyrax_metadata) do
    { title: ["Great"],
      creator: ["Stephen Hawking"],
      keyword: ["physics"],
      rights: ["Yes"],
      resource_type: ["ImageWork"] }
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
    mapper.metadata = { "rights" => "Yes" }
    expect(mapper.map_field(:rights)).to eq(["Yes"])
  end

  it "maps the required resource_type field" do
    mapper.metadata = { "resource_type" => "ImageWork" }
    expect(mapper.map_field(:resource_type)).to eq(["ImageWork"])
  end

  it "provides all the necessary fields" do
    mapper.metadata = image_work_metadata

    expect(input_record.attributes.eql?(hyrax_metadata)).to be_truthy
  end
end
