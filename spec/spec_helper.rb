# frozen_string_literal: true

require 'bundler/setup'
require 'active_record'
require 'external_id'
require 'factory_bot'

# Setup test database
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Load schema
ActiveRecord::Schema.define do
  create_table :external_ids, id: :string, force: true do |t|
    t.string :provider, null: false, index: true
    t.string :external_id, null: false
    t.references :resource, polymorphic: true, null: false, index: true, type: :string
    t.timestamps
  end

  add_index :external_ids, %i[provider resource_type resource_id], unique: true,
                                                                    name: 'index_one_external_id_per_resource'

  create_table :test_models, id: :string, force: true do |t|
    t.string :name
    t.timestamps
  end
end

# Configure ExternalId
ExternalId.configure do |config|
  config.providers = [:raynet, :salesforce]
  config.use_uuid = true
end

# Setup enum after configuration
ExternalId::ExternalId.setup_enum!

# Test model
class TestModel < ActiveRecord::Base
  include ExternalId::WithExternalId

  before_create :set_id

  private

  def set_id
    self.id ||= SecureRandom.uuid
  end
end

# Configure FactoryBot
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.before(:each) do
    # Clean up database before each test
    ExternalId::ExternalId.delete_all
    TestModel.delete_all
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
