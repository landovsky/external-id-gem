# frozen_string_literal: true

module ExternalId
  class Railtie < Rails::Railtie
    initializer 'external_id.active_record' do
      ActiveSupport.on_load(:active_record) do
        # Make the concern available to all ActiveRecord models
        # Users will still need to explicitly include it
      end
    end
  end
end
