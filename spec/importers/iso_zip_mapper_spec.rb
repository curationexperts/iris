# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IsoZipMapper do
  subject(:mapper) { described_class.new }

  let(:zip) do
    Zip::File.open(Pathname.new('spec/fixtures/import_zips/gford-20140000-010011_belfor1r.zip'))
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
    it { expect(mapper.input_fields).to include :zip }
    it { expect(mapper.input_fields).to include :iso }
  end

  describe '#iso' do
    it 'raises an error when no metadata is set' do
      expect { mapper.iso }.to raise_error(/\#metadata=/)
    end

    context 'with metadata' do
      before { mapper.metadata = zip }
      after { zip.close }

      it 'is an XML document' do
        expect(mapper.iso).to be_a Nokogiri::XML::Document
      end
    end
  end

  describe '#geo_mime_type' do
    subject { mapper.geo_mime_type }

    before { mapper.metadata = zip }
    after { zip.close }

    context 'for a shapefile' do
      it { is_expected.to eq 'application/zip; ogr-format="ESRI Shapefile"' }
    end

    context 'for a geotiff file' do
      let(:zip) { Zip::File.open(Pathname.new('spec/fixtures/import_zips/gford-20140000-010045_rbmgrd-t.zip')) }

      it { is_expected.to eq 'image/tiff; gdal-format=GTiff' }
    end

    context 'for a binary GRID file' do
      let(:zip) { Zip::File.open(Pathname.new('spec/fixtures/import_zips/gford-20140000-010052_utm_mayatopo.zip')) }

      it { is_expected.to eq 'application/octet-stream; gdal-format=AIG' }
    end
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    before { mapper.metadata = zip }
    after { zip.close }

    context 'for a shapefile' do
      it { is_expected.to eq ['VectorWork'] }
    end

    context 'for a geotiff file' do
      let(:zip) { Zip::File.open(Pathname.new('spec/fixtures/import_zips/gford-20140000-010045_rbmgrd-t.zip')) }

      it { is_expected.to eq ['RasterWork'] }
    end

    context 'for a binary GRID file' do
      let(:zip) { Zip::File.open(Pathname.new('spec/fixtures/import_zips/gford-20140000-010052_utm_mayatopo.zip')) }

      it { is_expected.to eq ['RasterWork'] }
    end
  end

  describe 'metadata properties' do
    context 'from an iso19139 source' do
      before { mapper.metadata = zip }
      after { zip.close }

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

      it "maps the keyword" do
        expect(mapper.keyword).to contain_exactly 'Forest biodiversity'
      end

      # TODO: confirm strings are the correct format to return,
      # and range is formatted correctly, and that zip samples are right
      describe "mapping temporal" do
        context "when a timePeriod is found" do
          it "returns two DateStrings in a string with a dash between them" do
            expect(mapper.temporal).to contain_exactly "1985-01-01T00:00:00 - 1992-01-01T00:00:00"
          end
        end

        context 'when a TimeInstant is found' do
          let(:zip) do
            Zip::File.open(Pathname.new('spec/fixtures/import_zips/gford-20140000-010045_rbmgrd-t.zip'))
          end
          it "returns a DateString" do
            expect(mapper.temporal).to contain_exactly "2000-03-01T00:00:00"
          end
        end

        context 'when no time nodes are found' do
          let(:zip) do
            Zip::File.open(Pathname.new('spec/fixtures/import_zips/gford-20140000-010052_utm_mayatopo.zip'))
          end
          it "returns nil" do
            expect(mapper.temporal).to be nil
          end
        end
      end

      it "maps the bounding box fields and provides a GeoWorks::Coverage object" do
        expect(mapper.coverage).to eq("northlimit=18.491987; eastlimit=-87.852387; southlimit=17.748652; westlimit=-88.509256; units=degrees; projection=EPSG:4326")
      end

      it 'maps the provenance field to University of California, Santa Barbara' do
        expect(mapper.provenance).to eq('University of California, Santa Barbara')
      end
    end
  end
end
