# frozen_string_literal: true

module ExternalId
  class Railtie < Rails::Railtie
    initializer 'external_id.active_record' do
      ActiveSupport.on_load(:active_record) do
        # Make the concern available to all ActiveRecord models
        # Users will still need to explicitly include it

        # Enable auditing if the audited gem is loaded and configured
        # This runs after initializers so user configuration is available
        if defined?(Audited) && ::ExternalId.configuration.enable_auditing
          ::ExternalId::ExternalId.audited
        end
      end
    end
  end
end
