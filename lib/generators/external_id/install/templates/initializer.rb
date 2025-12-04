# frozen_string_literal: true

ExternalId.configure do |config|
  # Define the external ID providers your application will use
  # You can pass an array of symbols or a hash for enum configuration
  config.providers = [:raynet]
  
  # Optionally, use a hash to customize the enum values:
  # config.providers = {
  #   raynet: 'raynet',
  #   salesforce: 'salesforce',
  #   hubspot: 'hubspot'
  # }

  # Configure the base class for the ExternalId model
  # Default: 'ActiveRecord::Base'
  # Change this if you have a custom base class like ApplicationRecord or ApplicationResource
  # config.base_class = 'ApplicationRecord'

  # Use UUID for primary keys (recommended for distributed systems)
  # Default: true
  # config.use_uuid = true
end
