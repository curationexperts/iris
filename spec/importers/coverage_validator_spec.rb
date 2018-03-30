# frozen_string_literal: true
require 'rails_helper'
require 'support/shared_examples/a_validator'

RSpec.describe CoverageValidator do
  subject(:validator) { described_class.new }
  let(:parser) { IrisCsvParser.new(file: file) }
  let(:file) { File.open("#{fixture_path}/raster_example.csv") }
  let(:missing_northlimit) { File.open("#{fixture_path}/missing_northlimit.csv") }
  let(:missing_eastlimit) { File.open("#{fixture_path}/missing_eastlimit.csv") }
  let(:missing_southlimit) { File.open("#{fixture_path}/missing_southlimit.csv") }
  let(:missing_westlimit) { File.open("#{fixture_path}/missing_westlimit.csv") }
  let(:missing_limit_data) { File.open("#{fixture_path}/missing_limit_data.csv") }
  let(:invalid_parser) { IrisCsvParser.new(file: missing_northlimit) }
  let(:valid_parser) { parser }

  it_behaves_like 'a Darlingtonia::Validator'

  context "when a record does not have a NorthLimit field" do
    it "is not valid" do
      expect(validator.validate(parser: invalid_parser)).to contain_exactly(have_attributes(name: :missing_coverage_field))
    end
  end

  context "when a record does not have an EastLimit field" do
    let(:invalid_parser) { IrisCsvParser.new(file: missing_eastlimit) }
    it "is not valid" do
      expect(validator.validate(parser: invalid_parser)).to contain_exactly(have_attributes(name: :missing_coverage_field))
    end
  end

  context "when a record does not have a SouthLimit field" do
    let(:invalid_parser) { IrisCsvParser.new(file: missing_southlimit) }
    it "is not valid" do
      expect(validator.validate(parser: invalid_parser)).to contain_exactly(have_attributes(name: :missing_coverage_field))
    end
  end

  context "when a record does not have a WestLimit field" do
    let(:invalid_parser) { IrisCsvParser.new(file: missing_westlimit) }
    it "is not valid" do
      expect(validator.validate(parser: invalid_parser)).to contain_exactly(have_attributes(name: :missing_coverage_field))
    end
  end

  context "when  a record is missing limit data" do
    let(:invalid_parser) { IrisCsvParser.new(file: missing_limit_data) }
    it "is not valid" do
      expect(validator.validate(parser: invalid_parser)).to contain_exactly(have_attributes(name: :missing_coverage_field))
    end
  end

  context "when a record does have the four coverage fields" do
    it "is valid" do
      expect(validator.validate(parser: parser)).to be_empty
    end
  end
end
