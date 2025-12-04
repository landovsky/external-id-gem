# frozen_string_literal: true

FactoryBot.define do
  factory :external_id, class: 'ExternalId::ExternalId' do
    provider { 'raynet' }
    sequence(:external_id) { |n| "ext-#{n}" }
    association :resource, factory: :test_model
  end

  factory :test_model do
    sequence(:name) { |n| "Test Model #{n}" }
  end
end
