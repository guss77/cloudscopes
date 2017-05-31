require 'cloudscopes'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!
  config.example_status_persistence_file_path = File.expand_path("../examples.state", __FILE__)
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand(config.seed)
  # uncomment for profiling slow examples
  #config.profile_examples = 10
end
