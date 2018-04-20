namespace :iris do
  namespace :import do
    desc 'Import Belize vegetation (vector sample data)'
    task belize: :environment do
      config = Rails.application.config_for(:importer)
      file = File.open(File.join(config['file_path'], 'gford-20140000-010015_belvegr.csv'))

      parser = IrisCsvParser.new(file: file)

      Importer.new(parser: parser).import

      file.close
    end

    desc 'Import Guatemala elevation (raster sample data)'
    task guatemala: :environment do
      config = Rails.application.config_for(:importer)
      file = File.open(File.join(config['file_path'], 'zipped_raster_example.csv'))

      parser = IrisCsvParser.new(file: file)

      Importer.new(parser: parser).import

      file.close
    end

    desc 'Run sample import of fixture csv'
    task import_sample_record: :environment do
      config = Rails.application.config_for(:importer)
      file = File.open(File.join(config['file_path'], 'raster_example.csv'))

      parser = IrisCsvParser.new(file: file)

      Importer.new(parser: parser).import

      file.close
    end

    desc 'Import with a supplied csv'
    task :from_a_csv, [:filename] => [:environment] do |_task, args|
      config = Rails.application.config_for(:importer)
      file = File.open(File.join(config['file_path'], args[:filename]))

      parser = IrisCsvParser.new(file: file)

      Importer.new(parser: parser).import if parser.validate

      file.close
    end

    desc 'Import from a directory of ZIPs'
    task :from_zips, [:path] => [:environment] do |_task, args|
      parser = IrisZipParser.new(file: args[:path])

      Importer.new(parser: parser, record_importer: ZipRecordImporter.new).import
    end
  end
end
