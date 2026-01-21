# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExternalId::WithExternalId do
  let(:test_class) { TestModel }
  let(:test_instance) { test_class.create!(name: 'Test') }

  describe '.find_by_external_id' do
    let(:record) { test_class.create!(name: 'Test Record') }
    let(:external_id) { create(:external_id, provider: 'raynet', external_id: '12345', resource: record) }

    before do
      allow(test_class).to receive(:name).and_return('TestModel')
    end

    context 'when external id exists' do
      it 'returns the associated resource when using string id' do
        external_id

        result = test_class.find_by_external_id('raynet', '12345')

        expect(result).to eq(record)
      end

      it 'returns the associated resource when using integer id' do
        external_id

        result = test_class.find_by_external_id('raynet', 12_345)

        expect(result).to eq(record)
      end
    end

    it 'returns nil when external id does not exist' do
      result = test_class.find_by_external_id('raynet', 'nonexistent')

      expect(result).to be_nil
    end

    it 'raises an error when provider does not exist' do
      expect do
        test_class.find_by_external_id('nonexistent', '12345')
      end.to raise_error(ArgumentError, /Provider must be one of/)
    end
  end

  describe '#add_external_id' do
    context 'when passing ExternalId::Value object' do
      let(:external_id_value) { ExternalId::Value.new(provider: 'raynet', id: '12345') }

      it 'creates external id from ExternalId::Value object' do
        expect do
          test_instance.add_external_id(external_id_value)
        end.to change { ExternalId::Record.count }.by(1)

        external_id = ExternalId::Record.last
        expect(external_id.provider).to eq('raynet')
        expect(external_id.external_id).to eq('12345')
        expect(external_id.resource).to eq(test_instance)
      end
    end

    context 'when passing nil as external_id_object' do
      it 'creates external id from provider and id parameters' do
        expect do
          test_instance.add_external_id(nil, provider: 'raynet', id: '12345')
        end.to change { ExternalId::Record.count }.by(1)

        external_id = ExternalId::Record.last
        expect(external_id.provider).to eq('raynet')
        expect(external_id.external_id).to eq('12345')
        expect(external_id.resource).to eq(test_instance)
      end
    end

    context 'when passing non-ExternalId::Value object' do
      it 'creates external id from provider and id parameters' do
        expect do
          test_instance.add_external_id('some_string', provider: 'raynet', id: '12345')
        end.to change { ExternalId::Record.count }.by(1)

        external_id = ExternalId::Record.last
        expect(external_id.provider).to eq('raynet')
        expect(external_id.external_id).to eq('12345')
        expect(external_id.resource).to eq(test_instance)
      end
    end

    context 'when external id already exists' do
      before do
        create(:external_id, provider: 'raynet', external_id: '12345', resource: test_instance)
      end

      it 'finds and returns the existing external id' do
        expect do
          test_instance.add_external_id(nil, provider: 'raynet', id: '12345')
        end.not_to change { ExternalId::Record.count }

        external_id = ExternalId::Record.last
        expect(external_id.provider).to eq('raynet')
        expect(external_id.external_id).to eq('12345')
        expect(external_id.resource).to eq(test_instance)
      end
    end

    context 'when no parameters provided' do
      it 'raises an error' do
        expect do
          test_instance.add_external_id
        end.to raise_error('Either ExternalId::Value or provider and id are required')
      end
    end
  end

  describe '#external_id' do
    context 'when eid exists' do
      let(:external_id) { create(:external_id, provider: 'raynet', external_id: '12345', resource: test_instance) }

      before do
        test_instance.eid = external_id
      end

      it 'returns ExternalId::Value from eid' do
        result = test_instance.external_id

        expect(result).to be_a(ExternalId::Value)
        expect(result.provider).to eq('raynet')
        expect(result.id).to eq('12345')
        expect(result).to be_present
      end
    end

    context 'when eid does not exist' do
      it 'returns blank ExternalId::Value' do
        result = test_instance.external_id

        expect(result).to be_a(ExternalId::Value)
        expect(result).to be_blank
        expect(result.provider).to be_nil
        expect(result.id).to be_nil
      end
    end

    context 'when eid is nil' do
      before do
        test_instance.eid = nil
      end

      it 'returns blank ExternalId::Value' do
        result = test_instance.external_id

        expect(result).to be_a(ExternalId::Value)
        expect(result).to be_blank
      end
    end
  end

  describe 'integration tests' do
    it 'works with TestModel' do
      expect(test_instance).to respond_to(:eid)
      expect(test_instance).to respond_to(:add_external_id)
      expect(test_instance).to respond_to(:external_id)
      expect(test_class).to respond_to(:find_by_external_id)
    end

    it 'can add and retrieve external id' do
      test_instance.add_external_id(nil, provider: 'raynet', id: 'test123')

      external_id_value = test_instance.external_id
      expect(external_id_value.provider).to eq('raynet')
      expect(external_id_value.id).to eq('test123')

      found_record = test_class.find_by_external_id('raynet', 'test123')
      expect(found_record).to eq(test_instance)
    end
  end
end
