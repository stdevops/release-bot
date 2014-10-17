module Command
  module Rake
    class Release < Base
      include FileUtils
      
      attr_reader :repo, :dir
      
      depends Git::Clone, :repo, lambda {|result|
        @dir = result[2]
      }
      depends Rubygems::Authenticate
      depends Git::Config, :dir
      
      def initialize(repo)
        @repo = repo
      end
      
      def execute
        cd dir do
          File.write('release.rb', <<-SCRIPT)
require 'rake'
require 'bundler/gem_helper'
helper = Bundler::GemHelper.new
helper.install
Rake::Task['release'].invoke
          SCRIPT
          sh "ruby release.rb"
        end
        nil
      end
    end
  end
end
