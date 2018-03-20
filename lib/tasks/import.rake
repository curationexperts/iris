namespace :iris do
  namespace :import do
    desc 'Run sample import of fixture csv'
    task import_sample_record: :environment do
      parser = IrisCsvParser.new(file: File.open('spec/fixtures/example.csv'))

      Importer.new(parser: parser).import
    end
  end
end
