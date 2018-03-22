# frozen_string_literal: true
require 'rails_helper'

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
end
