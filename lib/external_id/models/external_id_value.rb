# frozen_string_literal: true

module ExternalId
  # ExternalId value object
  class ExternalIdValue
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_accessor :provider, :id

    validates :provider, presence: true
    validates :id, presence: true

    def self.blank
      new
    end

    # Create from ExternalId model
    def self.from_model(external_id_model)
      return blank if external_id_model.blank?

      new(
        provider: external_id_model.provider,
        id: external_id_model.external_id
      )
    end

    # Create from array format [provider, id]
    def self.from_array(array)
      return blank if array.blank? || !array.is_a?(Array) || array.size != 2

      provider, id = array

      new(provider: provider, id: id)
    end

    def initialize(provider: nil, id: nil)
      @provider = provider.present? ? provider.to_s : provider
      @id = id.present? ? id.to_s : id
    end

    def present?
      provider.present? && id.present?
    end

    def blank?
      !present?
    end

    def ==(other)
      return false unless other.is_a?(ExternalIdValue)

      provider == other.provider && id == other.id
    end

    def to_s
      return '' if blank?

      "#{provider}:#{id}"
    end

    def to_hash
      return {} if blank?

      {
        provider: provider,
        id: id
      }
    end

    # Alias for compatibility
    alias_method :attributes, :to_hash

    def to_a
      return [] if blank?

      [provider, id]
    end
  end
end
