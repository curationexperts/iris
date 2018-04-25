# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Importing from a directory of zip files:' do
  let(:importer) { Importer.new(parser: parser, record_importer: rec_importer) }
  let(:parser) { IrisZipParser.new(file: zip_path) }
  let(:zip_path) { File.join(fixture_path, 'import_zips_in_dir') }
  let(:rec_importer) { ZipRecordImporter.new }

  context 'a raster and a vector work' do
    let(:raster) { RasterWork.first }
    let(:vector) { VectorWork.first }

    before do
      expect(RasterWork.count).to eq 0
      expect(VectorWork.count).to eq 0
    end

    it 'creates the works with the files attached' do
      expect { importer.import }
        .to change { RasterWork.count }.by(1)
        .and change { VectorWork.count }.by(1)
        .and change { FileSet.count }.by(3)

      expect(raster.visibility).to eq 'open'
      expect(vector.visibility).to eq 'open'

      # Check the attached files for the raster
      tif_file, zip_file = raster.ordered_members.to_a

      # TIFF file should be representative file
      expect(tif_file.geo_mime_type).to eq 'image/tiff; gdal-format=GTiff'
      expect(tif_file.label).to eq 'gford-20140000-010045_rbmgrd-t.tif'
      expect(raster.representative_id).to eq tif_file.id
      expect(tif_file.visibility).to eq 'open'

      # The zip file needs geo_mime_type nil or else geo_works will try to run image processing on it, and background jobs will fail.
      expect(zip_file.geo_mime_type).to eq nil
      expect(zip_file.label).to eq 'gford-20140000-010045_rbmgrd-t.zip'
      expect(zip_file.visibility).to eq 'open'

      # Check the attached files for the vector
      expect(vector.ordered_members.to_a.size).to eq 1
      shapefile = vector.ordered_members.to_a.first
      expect(shapefile.geo_mime_type).to eq 'application/zip; ogr-format="ESRI Shapefile"'
      expect(vector.representative_id).to eq shapefile.id
      expect(shapefile.visibility).to eq 'open'
    end
  end
end
