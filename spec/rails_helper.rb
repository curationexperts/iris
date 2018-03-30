# This file is copied to spec/ when you run 'rails generate rspec:install'

if ENV['COVERAGE'] || ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!('rails')
end

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

require 'active_fedora/cleaner'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:suite) do
    ActiveJob::Base.queue_adapter = :test
    ActiveFedora::Cleaner.clean!
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do |example|
    ActiveFedora::Cleaner.clean! if ActiveFedora::Base.count > 0

    if example.metadata[:type] == :feature && Capybara.current_driver != :rack_test
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end

    Hyrax::Workflow::WorkflowImporter.load_workflows
  end

  # Pass ':admin_set' to your specs if you need the default AdminSet to exist.
  config.before(:each, :admin_set) do
    # Create Hyrax's expected magic roles
    Sipity::Role.find_or_create_by(name: 'depositing')
    Sipity::Role.find_or_create_by(name: 'managing')
    AdminSet.find_or_create_default_admin_set_id
  end

  # Use this example group when you want to perform jobs inline during testing.
  #
  # Limit to specific job classes with:
  # ActiveJob::Base.queue_adapter.filter = [IngestFileJob]
  #
  # Note: If you run CharacterizeJob, you'll want to
  # stub out the part that calls fits since we don't
  # have fits on the travis build:
  # allow(Hydra::Works::CharacterizationService).to receive(:run)
  #
  config.before(perform_enqueued: true) do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
  end

  config.after(perform_enqueued: true) do
    ActiveJob::Base.queue_adapter.enqueued_jobs  = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = false
    ActiveJob::Base.queue_adapter = :test
  end
end
