# This class represents a file that the importer will
# attach to the work.  It helps the Hyrax::Actors::FileActor
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
