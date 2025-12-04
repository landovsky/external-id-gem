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

      def create_migration
        migration_template 'migration.rb.tt', File.join(db_migrate_path, 'create_external_ids.rb')
      end

      def show_readme
        readme 'README' if behavior == :invoke
      end

      private

      def db_migrate_path
        if defined?(Rails.application) && Rails.application.config.paths['db/migrate']
          Rails.application.config.paths['db/migrate'].to_a.first
        else
          'db/migrate'
        end
      end
    end
  end
end
