module Crocodoc
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      class_option :api_token, :type => :string, :banner => 'Your Crocodoc API token', :required => true

      def create_config_file
        template 'crocodoc.yml', File.join('config', 'crocodoc.yml')
      end

      def create_initializer
        template 'initializer.rb', File.join('config', 'initializers', 'crocodoc.rb')
      end

      desc <<DESC
Description:
    Copies Crocodoc configuration file to your application's initializer directory.
DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end
    end
  end
end
