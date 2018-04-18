require 'rails_helper'

describe DocumentBuilder::ReferencesBuilder do
  # For building the geoblacklight solr document
  let(:doc_builder) { GeoWorks::Discovery::DocumentBuilder.new(work_presenter, GeoWorks::Discovery::GeoblacklightDocument.new) }
  let(:document) { JSON.parse(doc_builder.to_json(nil)) }

  let(:work) { RasterWork.new(id: '123456', title: ['Geo Work'], coverage: coverage.to_s, visibility: visibility) }
  let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:coverage) { GeoWorks::Coverage.new(43.0, -69.8, 42.9, -71.0) }

  let(:zip_file) { FileSet.new(id: 'zip_file_id', label: 'my_file.zip', geo_mime_type: nil) }
  let(:tif_file) { FileSet.new(id: 'tif_file_id', label: 'my_file.tif', geo_mime_type: 'image/tiff; gdal-format=GTiff') }

  let(:work_presenter) { GeoWorks::RasterWorkShowPresenter.new(SolrDocument.new(work.to_solr), nil) }
  let(:zip_presenter) { Hyrax::FileSetPresenter.new(SolrDocument.new(zip_file.to_solr), nil) }
  let(:tif_presenter) { Hyrax::FileSetPresenter.new(SolrDocument.new(tif_file.to_solr), nil) }

  let(:req) { RequestShim.new }
  let(:zip_download_link) { "#{req.protocol}#{req.host}/downloads/#{zip_file.id}" }
  let(:tif_download_link) { "#{req.protocol}#{req.host}/downloads/#{tif_file.id}" }

  before do
    allow(work_presenter).to receive(:request).and_return(req)
  end

  describe 'File download URL:' do
    context 'A work where 1st file is raster and 2nd file is zip' do
      before do
        allow(work_presenter).to receive(:file_set_presenters).and_return([tif_presenter, zip_presenter])
      end

      it 'returns download link for the zip file' do
        refs = JSON.parse(document['dct_references_s'])
        expect(refs['http://schema.org/downloadUrl']).to eq zip_download_link
      end
    end

    context 'when it can\'t find the zip file' do
      let(:zip_file) { FileSet.new(id: 'zip_file_id') }

      before do
        allow(work_presenter).to receive(:file_set_presenters).and_return([tif_presenter, zip_presenter])
      end

      it 'gracefully falls back to parent class behavior' do
        expect(zip_file.label).to eq nil # it won't be able to select the zip file
        refs = JSON.parse(document['dct_references_s'])
        expect(refs['http://schema.org/downloadUrl']).to eq tif_download_link
      end
    end

    context 'A work with more than one zip file' do
      let(:zip_file_2) { FileSet.new(id: 'zip_2_id', label: 'my_file_2.zip') }
      let(:zip_2_presenter) { Hyrax::FileSetPresenter.new(SolrDocument.new(zip_file_2.to_solr), nil) }

      before do
        allow(work_presenter).to receive(:file_set_presenters).and_return([zip_presenter, zip_2_presenter])
      end

      it 'returns the download link for the first zip file' do
        refs = JSON.parse(document['dct_references_s'])
        expect(refs['http://schema.org/downloadUrl']).to eq zip_download_link
      end
    end

    context 'A work with no files attached' do
      it 'gracefully returns nothing' do
        refs = JSON.parse(document['dct_references_s'])
        expect(refs['http://schema.org/downloadUrl']).to eq nil
      end
    end
  end
end
