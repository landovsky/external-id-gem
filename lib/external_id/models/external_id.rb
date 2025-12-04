# frozen_string_literal: true

module ExternalId
  class ExternalId < ActiveRecord::Base
    self.table_name = 'external_ids'

    belongs_to :resource, polymorphic: true

    validates :provider, presence: true
    validates :external_id, presence: true

    before_create :set_id_if_needed

    private

    def set_id_if_needed
      return unless id.nil? && ::ExternalId.configuration.use_uuid

      self.id = SecureRandom.uuid
    end

    public

    # Define enum dynamically based on configuration
    def self.providers
      @providers ||= ::ExternalId.configuration.providers
    end

    # Set up enum if providers are configured
    def self.setup_enum!
      return if providers.empty?

      enum :provider, providers, prefix: true
    end

    # Call setup when the class is loaded
    def self.inherited(subclass)
      super
      subclass.setup_enum! if subclass == ExternalId::ExternalId
    end
  end
end

# Setup enum after configuration
ExternalId::ExternalId.setup_enum! if defined?(Rails) && Rails.application
