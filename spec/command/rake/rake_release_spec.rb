require 'spec_helper'
require 'command/rake'

include Command::Rake

describe Release do
  describe "dependencies" do
    let(:dependencies) { Release.dependencies }
    it "matches" do
      expect(dependencies).to match([
        [ Command::Git::Clone, Command::Git::Clone, [ :repo, an_instance_of(Proc) ] ],
        [ Command::Rubygems::Authenticate, Command::Rubygems::Authenticate, [] ], 
        [ Command::Git::Config, Command::Git::Config, [:dir] ]
      ])
    end
  end
  describe "perform" do
    let(:repo) { "the-repo" }
    let(:command) { Release.new(repo) }
    it "matches" do
      Dir.tmpdir do |dir|
        expect_any_instance_of(Command::Git::Clone).to receive(:perform).and_return([ nil, nil, dir ])
        expect_any_instance_of(Command::Rubygems::Authenticate).to receive(:perform)
        expect_any_instance_of(Command::Git::Config).to receive(:perform)
        expect(command).to receive(:cd).with(dir)
        expect(command).to receive(:sh).with("ruby release.rb")
        command.perform
      end
    end
  end
end