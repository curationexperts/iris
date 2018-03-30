# frozen_string_literal: true
require 'rails_helper'
require 'support/shared_examples/a_validator'

RSpec.describe ProvenanceValidator do
  subject(:validator) { described_class.new }
  let(:parser) { IrisCsvParser.new(file: file) }
  let(:file) { File.open("#{fixture_path}/raster_example.csv") }
  let(:invalid_file) { File.open("#{fixture_path}/missing_provenance.csv") }

  let(:invalid_parser) { IrisCsvParser.new(file: invalid_file) }
  let(:valid_parser) { parser }

  it_behaves_like 'a Darlingtonia::Validator'

  context "when a record does not have a provenance field" do
    it "is not valid" do
      expect(validator.validate(parser: invalid_parser)).to contain_exactly(have_attributes(name: :missing_provenance))
    end
  end

  context "when a record does have a provenance field" do
    it "is valid" do
      expect(validator.validate(parser: parser)).to be_empty
    end
  end
end
