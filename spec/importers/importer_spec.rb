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

  it "creates an ImageWork from a one-row csv", :clean do
    expect { importer.import }.to change { ImageWork.count }.by 1
  end
end
