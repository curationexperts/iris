# frozen_string_literal: true
require 'rails_helper'
require 'rake'

describe "iris:import" do
  let(:rake) { Rake::Application.new }
  let(:task_path) { "lib/tasks/import" }
  # typical task, identical to the others in file handling
  let(:iris_import) { rake['iris:import:guatemala'] }
  let(:file) { double }
  let(:csv) { double }
  let(:config) { Rails.application.config_for(:importer) }

  def loaded_files_excluding_current_rake_file
    $LOADED_FEATURES.reject { |file| file == Rails.root.join("#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment)
  end

  it "closes the file the Importer opens for parsing records" do
    allow(File).to receive(:open) { file }
    allow(file).to receive(:rewind)
    allow(file).to receive(:read)
    allow(csv).to receive(:each)
    allow(CSV).to receive(:parse).with(file.read, headers: true) { csv }

    expect(file).to receive(:close)

    iris_import.invoke
  end
end
