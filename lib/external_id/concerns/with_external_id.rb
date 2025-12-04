# frozen_string_literal: true

module ExternalId
  module WithExternalId
    extend ActiveSupport::Concern

    included do
      has_one :eid, class_name: 'ExternalId::ExternalId', as: :resource, dependent: :destroy
    end

    class_methods do
      def find_by_external_id(provider, external_id)
        providers = ::ExternalId.configuration.providers
        unless providers.key?(provider.to_sym)
          raise ArgumentError,
                "Provider must be one of #{providers.keys}, was '#{provider}'"
        end

        ::ExternalId::ExternalId.find_by(provider: provider, external_id: external_id, resource_type: name)&.resource
      end
    end

    def add_external_id(external_id_object = nil, provider: nil, id: nil)
      if external_id_object.blank? && provider.blank? && id.blank?
        raise 'Either ExternalId::Value or provider and id are required'
      end

      eid = external_id_object.is_a?(::ExternalId::Value) ? external_id_object : ::ExternalId::Value.new(provider: provider, id: id)

      ::ExternalId::ExternalId.find_or_create_by!(provider: eid.provider, external_id: eid.id, resource: self)
    end

    def external_id
      ::ExternalId::Value.from_model(eid)
    end
  end
end
