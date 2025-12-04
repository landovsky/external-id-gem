# frozen_string_literal: true

module ExternalId
  class Configuration
    attr_accessor :providers, :base_class, :use_uuid

    def initialize
      @providers = {}
      @base_class = 'ActiveRecord::Base'
      @use_uuid = true
    end

    def providers=(value)
      if value.is_a?(Array)
        # Convert array to hash format expected by enum
        @providers = value.each_with_object({}) { |provider, hash| hash[provider.to_sym] = provider.to_s }
      elsif value.is_a?(Hash)
        @providers = value
      else
        raise ArgumentError, 'providers must be an Array or Hash'
      end
    end
  end
end
