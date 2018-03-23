# When you import a work using the importer, the CSV
# input file will contain a list of data files to
# attach to that work.
# This class represents a file that will be attached
# to the work.  It helps the Hyrax::Actors::FileActor
# and Hyrax::Actors::FileSetActor find the correct
# file on the filesystem.

class ImportFile
  def initialize(file_path)
    @file_path = file_path
  end

  def path
    @file_path
  end

  def original_filename
    ::File.basename(@file_path)
  end
end
