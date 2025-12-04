# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExternalId::Value do
  describe '.blank' do
    it 'returns a new blank instance' do
      result = described_class.blank

      expect(result).to be_a(described_class)
      expect(result.provider).to be_nil
      expect(result.id).to be_nil
      expect(result).to be_blank
    end
  end

  describe 'validations' do
    it 'validates presence of provider' do
      result = described_class.new(id: '12345')
      expect(result).to be_invalid
    end

    it 'validates presence of id' do
      result = described_class.new(provider: 'raynet')
      expect(result).to be_invalid
    end
  end

  describe '.from_model' do
    context 'when external_id_model is blank' do
      it 'returns a blank instance' do
        result = described_class.from_model(nil)

        expect(result).to be_a(described_class)
        expect(result).to be_blank
      end

      it 'returns a blank instance for empty string' do
        result = described_class.from_model('')

        expect(result).to be_a(described_class)
        expect(result).to be_blank
      end
    end

    context 'when external_id_model is present' do
      let(:external_id_model) { build(:external_id, provider: 'raynet', external_id: '12345') }

      it 'creates instance with provider and id from model' do
        result = described_class.from_model(external_id_model)

        expect(result.provider).to eq('raynet')
        expect(result.id).to eq('12345')
        expect(result).to be_present
      end
    end
  end

  describe '.from_array' do
    context 'when array is blank' do
      it 'returns a blank instance for nil' do
        result = described_class.from_array(nil)

        expect(result).to be_a(described_class)
        expect(result).to be_blank
      end

      it 'returns a blank instance for empty array' do
        result = described_class.from_array([])

        expect(result).to be_a(described_class)
        expect(result).to be_blank
      end
    end

    context 'when array is not an Array' do
      it 'returns a blank instance for string' do
        result = described_class.from_array('not_an_array')

        expect(result).to be_a(described_class)
        expect(result).to be_blank
      end

      it 'returns a blank instance for hash' do
        result = described_class.from_array({ provider: 'raynet', id: '12345' })

        expect(result).to be_a(described_class)
        expect(result).to be_blank
      end
    end

    context 'when array size is not 2' do
      it 'returns a blank instance for single element array' do
        result = described_class.from_array(['raynet'])

        expect(result).to be_a(described_class)
        expect(result).to be_blank
      end

      it 'returns a blank instance for three element array' do
        result = described_class.from_array(['raynet', '12345', 'extra'])

        expect(result).to be_a(described_class)
        expect(result).to be_blank
      end
    end

    context 'when provider is blank' do
      it 'returns a blank instance for nil provider' do
        result = described_class.from_array([nil, '12345'])

        expect(result).to be_a(described_class)
        expect(result.provider).to be_nil
        expect(result.id).to eq('12345')
      end

      it 'returns a blank instance for empty provider' do
        result = described_class.from_array(['', '12345'])

        expect(result).to be_a(described_class)
        expect(result.provider).to eq('')
        expect(result.id).to eq('12345')
      end
    end

    context 'when id is blank' do
      it 'returns a blank instance for nil id' do
        result = described_class.from_array(['raynet', nil])

        expect(result).to be_a(described_class)
        expect(result.provider).to eq('raynet')
        expect(result.id).to be_nil
      end

      it 'returns a blank instance for empty id' do
        result = described_class.from_array(['raynet', ''])

        expect(result).to be_a(described_class)
        expect(result.provider).to eq('raynet')
        expect(result.id).to eq('')
      end
    end

    context 'when array has valid provider and id' do
      it 'creates instance with provider and id from array' do
        result = described_class.from_array(['raynet', '12345'])

        expect(result.provider).to eq('raynet')
        expect(result.id).to eq('12345')
        expect(result).to be_present
      end

      it 'converts provider and id to strings' do
        result = described_class.from_array([:raynet, 12345])

        expect(result.provider).to eq('raynet')
        expect(result.id).to eq('12345')
        expect(result).to be_present
      end
    end
  end

  describe '#present?' do
    context 'when both provider and id are present' do
      it 'returns true' do
        instance = described_class.new(provider: 'raynet', id: '12345')

        expect(instance).to be_present
      end
    end

    context 'when provider is blank' do
      it 'returns false' do
        instance = described_class.new(provider: nil, id: '12345')

        expect(instance).not_to be_present
      end
    end

    context 'when id is blank' do
      it 'returns false' do
        instance = described_class.new(provider: 'raynet', id: nil)

        expect(instance).not_to be_present
      end
    end

    context 'when both provider and id are blank' do
      it 'returns false' do
        instance = described_class.new(provider: nil, id: nil)

        expect(instance).not_to be_present
      end
    end
  end

  describe '#blank?' do
    it 'returns the opposite of present?' do
      present_instance = described_class.new(provider: 'raynet', id: '12345')
      blank_instance = described_class.new(provider: nil, id: nil)

      expect(present_instance.blank?).to eq(!present_instance.present?)
      expect(blank_instance.blank?).to eq(!blank_instance.present?)
    end
  end

  describe '#==' do
    context 'when comparing with same class' do
      it 'returns true for identical instances' do
        instance1 = described_class.new(provider: 'raynet', id: '12345')
        instance2 = described_class.new(provider: 'raynet', id: '12345')

        expect(instance1).to eq(instance2)
      end

      it 'returns false for different providers' do
        instance1 = described_class.new(provider: 'raynet', id: '12345')
        instance2 = described_class.new(provider: 'other', id: '12345')

        expect(instance1).not_to eq(instance2)
      end

      it 'returns false for different ids' do
        instance1 = described_class.new(provider: 'raynet', id: '12345')
        instance2 = described_class.new(provider: 'raynet', id: '67890')

        expect(instance1).not_to eq(instance2)
      end

      it 'returns true for blank instances' do
        instance1 = described_class.new
        instance2 = described_class.new

        expect(instance1).to eq(instance2)
      end
    end

    context 'when comparing with different class' do
      it 'returns false' do
        instance = described_class.new(provider: 'raynet', id: '12345')
        other_object = 'not an ExternalId::Value'

        expect(instance).not_to eq(other_object)
      end
    end
  end

  describe '#to_s' do
    context 'when instance is blank' do
      it 'returns empty string' do
        instance = described_class.new

        expect(instance.to_s).to eq('')
      end
    end

    context 'when instance is present' do
      it 'returns formatted string with provider and id' do
        instance = described_class.new(provider: 'raynet', id: '12345')

        expect(instance.to_s).to eq('raynet:12345')
      end
    end
  end

  describe '#to_hash' do
    context 'when instance is blank' do
      it 'returns empty hash' do
        instance = described_class.new

        expect(instance.to_hash).to eq({})
      end
    end

    context 'when instance is present' do
      it 'returns hash with provider and id' do
        instance = described_class.new(provider: 'raynet', id: '12345')

        expect(instance.to_hash).to eq({
          provider: 'raynet',
          id: '12345'
        })
      end
    end
  end
end
