namespace :iris do
  namespace :import do
    desc 'Import from a directory of ZIPs'
    task :from_zips, [:path] => [:environment] do |_task, args|
      require 'zip'
      parser = IrisZipParser.new(file: args[:path])
      Importer.new(parser: parser, record_importer: ZipRecordImporter.new).import
    end
  end
end
