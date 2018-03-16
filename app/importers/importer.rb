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

    def default_creator
      User.find_or_create_system_user(config['user_key'])
    end

    def default_record_importer
      IrisRecordImporter.new(
        creator: default_creator,
        file_path: config['file_path']
      )
    end
end
