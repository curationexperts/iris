# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IrisCsvParser do
  subject(:parser) { described_class.new(file: file) }
  let(:file)       { File.open(csv_path) }

  describe '#records' do
    context "with an empty row" do
      let(:csv_path) { 'spec/fixtures/empty_row_example.csv' }
      it 'will not create a record' do
        expect(parser.records.count).to eq 0
      end
    end
  end

  describe '#validate' do
    let(:csv_path) { 'spec/fixtures/missing_title.csv' }
    it 'requires a title' do
      expect { parser.validate }
        .to change { parser.errors }
        .to include have_attributes(name: :missing_title)
    end
  end
end
