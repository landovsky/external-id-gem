# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module ExternalId
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path('install/templates', __dir__)

      desc 'Creates ExternalId initializer and migration'

      def copy_initializer
        template 'initializer.rb', 'config/initializers/external_id.rb'
      end

      def copy_migration
        @use_uuid = ExternalId.configuration.use_uuid rescue false
        migration_template 'migration.rb.tt', 'create_external_ids.rb'
      end

      def show_readme
        readme 'README' if behavior == :invoke
      end
    end
  end
end
