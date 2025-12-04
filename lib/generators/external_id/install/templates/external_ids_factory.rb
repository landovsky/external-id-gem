# frozen_string_literal: true

FactoryBot.define do
  factory :external_id, class: 'ExternalId::ExternalId' do
    provider { 'default_provider' }
    sequence(:external_id) { |n| "ext-#{n}" }
    # association :resource, factory: :your_model
  end
end
