# frozen_string_literal: true
class Importer < Darlingtonia::Importer
  def initialize(parser:, record_importer: default_record_importer)
    super
  end

  def self.config
    Rails.application.config_for(:importer)
  end

  def config
    self.class.config
  end

  private

    def default_record_importer
      ZipRecordImporter.new
    end
end
