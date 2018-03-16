# frozen_string_literal: true
class IrisCsvParser < Darlingtonia::CsvParser
  DEFAULT_VALIDATORS = [Darlingtonia::CsvFormatValidator.new,
                        Darlingtonia::TitleValidator.new].freeze
  def records
    return enum_for(:records) unless block_given?
    file.rewind
    # use the IrisMapper
    CSV.parse(file.read, headers: true).each do |row|
      next if row.to_h.values.all?(&:nil?)
      yield Darlingtonia::InputRecord.from(metadata: row, mapper: IrisMapper.new)
    end
  rescue CSV::MalformedCSVError
    # error reporting for this case is handled by validation
    []
  end
end
