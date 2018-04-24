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

  describe 'metadata properties' do
    # keyword: ["physics"],
    # rights: ["http://creativecommons.org/publicdomain/zero/1.0/"],

    # visibility: nil,


    context 'with metadata from ISO' do
      before { mapper.metadata = zip }

      it 'maps the title' do
        expect(mapper.title)
          .to contain_exactly 'Forest Cover, Maya Forest, Belize (Northeast), 1995'
      end

      it "maps the creator" do
        expect(mapper.creator).to contain_exactly "University of Florida. GeoPlan Center"
      end

      it "maps the spatial property" do
        expect(mapper.spatial).to contain_exactly 'Belize'
      end

      # TODO: confirm strings are the correct format to return,
      # and range is formatted correctly, and that zip samples are right
      describe "mapping the temporal property" do
        context "when a timePeriod is found" do
          it "maps the temporal" do
            expect(mapper.temporal).to eq "1985-01-01T00:00:00 - 1992-01-01T00:00:00"
          end
        end

        context 'when a TimeInstant is found' do
          let(:zip) do
            Zip::File.open('spec/fixtures/import_zips/gford-20140000-010052_utm_mayatopo.zip')
          end
          it "maps the temporal" do
            expect(mapper.temporal).to eq "2000-03-01T00:00:00"
          end
        end

        context 'when no temporal property is found' do
          let(:zip) do
            Zip::File.open('spec/fixtures/import_zips/gford-20140000-010045_rbmgrd-t.zip')
          end
          it "maps the temporal" do
            expect(mapper.temporal).to eq ""
          end
        end
      end

      it "maps the bounding box fields and provides a GeoWorks::Coverage object" do
        expect(mapper.coverage).to eq("northlimit=18.491987; eastlimit=-87.852387; southlimit=17.748652; westlimit=-88.509256; units=degrees; projection=EPSG:4326")
      end

      it 'maps the provenance field' do
        expect(mapper.provenance).to eq('University of California, Santa Barbara')
      end
    end
  end
end
