# frozen_string_literal: true

require 'active_record'
require 'active_support'

require_relative 'external_id/version'
require_relative 'external_id/configuration'
require_relative 'external_id/models/external_id_value'
require_relative 'external_id/models/external_id'
require_relative 'external_id/concerns/with_external_id'

module ExternalId
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end

require 'external_id/railtie' if defined?(Rails::Railtie)
