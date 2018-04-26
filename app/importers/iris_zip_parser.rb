# frozen_string_literal: true
class IrisZipParser < Darlingtonia::Parser
  ##
  # @see Darlingtonia::Parser#records
  def records
    return enum_for(:records) unless block_given?

    zips.each do |zip|
      yield IrisInputRecord.from(metadata: zip, mapper: IsoZipMapper.new)
    end
  end

  private

    def zip_paths
      Dir.entries(file)
         .select { |fname| fname.end_with?('.zip') }
         .map { |fname| Pathname.new(file).join(fname) }
    end

    def zips
      zip_paths.map { |fname| Zip::File.open(fname) }
    end
end
