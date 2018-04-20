# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IrisZipParser do
  subject(:parser) { described_class.new(file: file) }
  let(:file)       { 'spec/fixtures/import_zips' }

  describe '#records' do
    it 'gives an enumerator' do
      expect(parser.records).to be_a Enumerator
    end

    it 'contains the records' do
      expect(parser.records).to contain_exactly(an_instance_of(IrisInputRecord),
                                                an_instance_of(IrisInputRecord),
                                                an_instance_of(IrisInputRecord),
                                                an_instance_of(IrisInputRecord))
    end

    context 'when the path contains no zip files' do
      let(:file) { 'spec/support' }

      it 'is empty' do
        expect(parser.records.to_a).to be_empty
      end
    end
  end
end
