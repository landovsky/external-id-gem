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
        migration_template 'migration.rb.tt', 'db/migrate/create_external_ids.rb'
      end

      def copy_factory
        return unless factory_bot_available?

        test_dir = detect_test_directory
        return unless test_dir

        factories_dir = File.join(test_dir, 'factories')
        empty_directory factories_dir unless File.directory?(factories_dir)

        template 'external_ids_factory.rb', File.join(factories_dir, 'external_ids.rb')
      end

      def show_readme
        readme 'README' if behavior == :invoke
      end

      private

      def factory_bot_available?
        return @factory_bot_available if defined?(@factory_bot_available)

        @factory_bot_available = begin
          # Check Gemfile for factory_bot
          gemfile_path = File.join(destination_root, 'Gemfile')
          if File.exist?(gemfile_path)
            gemfile_content = File.read(gemfile_path)
            gemfile_content.match?(/factory_bot|factory_girl/)
          else
            false
          end
        end
      end

      def detect_test_directory
        # Check common test directory names in order of preference
        %w[spec test rspec].each do |dir|
          path = File.join(destination_root, dir)
          return dir if File.directory?(path)
        end

        nil
      end
    end
  end
end
