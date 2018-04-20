# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IsoZipMapper do
  subject(:mapper) { described_class.new }

  let(:zip) do
    Zip::File.open('spec/fixtures/import_zips/gford-20140000-010011_belfor1r.zip')
  end

  describe '#fields' do
    it 'has a title' do
      expect(mapper.fields).to include :title
    end

    it 'has an iso document' do
      expect(mapper.fields).to include :iso
    end

    it 'has a resource type' do
      expect(mapper.fields).to include :resource_type
    end

    it 'has a zip' do
      expect(mapper.fields).to include :zip
    end
  end

  describe '#input_fields' do
    it { expect(mapper.input_fields).to include :resource_type }
    it { expect(mapper.input_fields).to include :zip }
    it { expect(mapper.input_fields).to include :iso }
  end

  describe '#iso' do
    it 'raises an error when no metadata is set' do
      expect { mapper.iso }.to raise_error(/\#metadata=/)
    end

    context 'with metadata' do
      before { mapper.metadata = zip }

      it 'is an XML document' do
        expect(mapper.iso).to be_a Nokogiri::XML::Document
      end
    end
  end

  describe '#title' do
    context 'with metadata' do
      before { mapper.metadata = zip }

      it 'maps the title from the ISO' do
        expect(mapper.title)
          .to contain_exactly 'Forest Cover, Maya Forest, Belize (Northeast), 1995'
      end
    end
  end
end
