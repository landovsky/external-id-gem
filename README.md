# ExternalId

A Rails gem that provides a clean, polymorphic way to associate external IDs from third-party systems (like CRMs, payment processors, or any external service) with your ActiveRecord models.

## Features

- Polymorphic associations - link external IDs to any model
- Type-safe with Rails enums for provider validation
- Value object pattern for clean external ID handling
- Unique constraints ensuring one external ID per provider per resource
- UUID support for distributed systems
- Configurable providers
- Full test coverage included

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'external-id'
```

Then execute:

```bash
bundle install
```

Run the installer:

```bash
rails generate external_id:install
```

This will create:
- An initializer at `config/initializers/external_id.rb`
- A migration for the `external_ids` table

Review the initializer and customize the providers, then run the migration:

```bash
rails db:migrate
```

## Configuration

Edit `config/initializers/external_id.rb`:

```ruby
ExternalId.configure do |config|
  # Define your external ID providers
  config.providers = [:raynet, :salesforce, :hubspot]

  # Or use a hash for custom enum values
  # config.providers = {
  #   raynet: 'raynet',
  #   salesforce: 'sf',
  #   hubspot: 'hs'
  # }

  # Optional: Configure base class (default: 'ActiveRecord::Base')
  # config.base_class = 'ApplicationRecord'

  # Optional: Use UUID for primary keys (default: true)
  # config.use_uuid = true
end
```

## Usage

### Include the concern in your models

```ruby
class Customer < ApplicationRecord
  include ExternalId::WithExternalId
end

class Order < ApplicationRecord
  include ExternalId::WithExternalId
end
```

### Add an external ID to a record

```ruby
customer = Customer.find(123)

# Option 1: Using keyword arguments
customer.add_external_id(provider: 'raynet', id: 'R-12345')

# Option 2: Using an ExternalIdValue object
external_id = ExternalId::ExternalIdValue.new(provider: 'salesforce', id: 'SF-67890')
customer.add_external_id(external_id)
```

### Find a record by external ID

```ruby
# Find customer by their Raynet ID
customer = Customer.find_by_external_id('raynet', 'R-12345')

# Returns nil if not found
customer = Customer.find_by_external_id('raynet', 'nonexistent')  # => nil

# Raises ArgumentError for unknown providers
Customer.find_by_external_id('unknown', '123')  # => ArgumentError
```

### Get the external ID from a record

```ruby
customer = Customer.find(123)

# Returns an ExternalIdValue object
external_id = customer.external_id

if external_id.present?
  puts external_id.provider  # => 'raynet'
  puts external_id.id        # => 'R-12345'
  puts external_id.to_s      # => 'raynet:R-12345'
  puts external_id.to_hash   # => { provider: 'raynet', id: 'R-12345' }
end

# Blank when no external ID exists
customer_without_eid = Customer.create(name: 'Test')
customer_without_eid.external_id.blank?  # => true
```

### Access the underlying ActiveRecord model

```ruby
customer = Customer.find(123)

# Access the external_id record directly
customer.eid  # => ExternalId::ExternalId instance or nil

# The association is dependent: :destroy
# Deleting the customer will also delete the external_id
```

## Database Schema

The gem creates an `external_ids` table with the following structure:

```ruby
create_table :external_ids, id: :uuid do |t|
  t.string :provider, null: false, index: true
  t.string :external_id, null: false
  t.references :resource, polymorphic: true, null: false, index: true, type: :uuid

  t.timestamps
end

add_index :external_ids, [:provider, :resource_type, :resource_id],
          unique: true, name: 'index_one_external_id_per_resource'
```

This ensures that each resource can only have one external ID per provider.

## ExternalIdValue

The `ExternalIdValue` class is a value object that provides a clean interface for working with external IDs:

```ruby
# Create a value object
eid = ExternalId::ExternalIdValue.new(provider: 'raynet', id: '12345')

# Check presence
eid.present?  # => true
eid.blank?    # => false

# String representation
eid.to_s      # => 'raynet:12345'

# Hash representation
eid.to_hash   # => { provider: 'raynet', id: '12345' }

# Array representation
eid.to_a      # => ['raynet', '12345']

# Create from array
ExternalId::ExternalIdValue.from_array(['raynet', '12345'])

# Create blank value
ExternalId::ExternalIdValue.blank  # => blank instance

# Comparison
eid1 = ExternalId::ExternalIdValue.new(provider: 'raynet', id: '123')
eid2 = ExternalId::ExternalIdValue.new(provider: 'raynet', id: '123')
eid1 == eid2  # => true
```

## Advanced Usage

### Custom scopes

You can add custom scopes to query external IDs:

```ruby
# In your application
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end

# Add custom scopes
class ExternalId::ExternalId
  scope :raynet, -> { where(provider: 'raynet') }
  scope :customers, -> { where(resource_type: 'Customer') }
end

# Use them
ExternalId::ExternalId.raynet.customers
```

### Handling multiple providers

```ruby
customer = Customer.find(123)

# Add IDs from different providers
customer.add_external_id(provider: 'raynet', id: 'R-12345')

# This will fail due to unique constraint (one ID per provider per resource)
customer.add_external_id(provider: 'raynet', id: 'R-99999')  # => ActiveRecord::RecordNotUnique

# But you can have the same customer in different systems
# by using a different provider (requires updating the resource)
# Note: Currently limited to one external_id per resource
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/external-id. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/external-id/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the External::Id project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/external-id/blob/main/CODE_OF_CONDUCT.md).
