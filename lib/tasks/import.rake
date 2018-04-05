namespace :iris do
  namespace :import do
    desc 'Import Belize vegetation (vector sample data)'
    task belize: :environment do
      file = File.join(ENV['IMPORTER_FILE_PATH'], 'gford-20140000-010015_belvegr.csv')
      parser = IrisCsvParser.new(file: File.open(file))

      Importer.new(parser: parser).import
    end

    desc 'Import Guatemala elevation (raster sample data)'
    task guatemala: :environment do
      file = File.join(ENV['IMPORTER_FILE_PATH'], 'gford-20140000-010045_rbmgrd-t.csv')
      parser = IrisCsvParser.new(file: File.open(file))

      Importer.new(parser: parser).import
    end

    desc 'Run sample import of fixture csv'
    task import_sample_record: :environment do
      parser = IrisCsvParser.new(file: File.open('spec/fixtures/raster_example.csv'))

      Importer.new(parser: parser).import
    end

    desc 'Import with a supplied csv'
    task :from_a_csv, [:filename] => [:environment] do |_task, args|
      parser = IrisCsvParser.new(file: File.open(args[:filename]))

      Importer.new(parser: parser).import if parser.validate
    end
  end
end
