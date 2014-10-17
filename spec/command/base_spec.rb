require 'spec_helper'

module CommandSpec
  class Cmd
  end
  
  class Test < Command::Base
    depends :command, Cmd
    depends Cmd
  end
end

describe Command::Base do
  describe "#depends" do
    let(:cmd_class) { CommandSpec::Test }
    describe "populates self.dependencies" do
      let(:dependencies) { cmd_class.dependencies }
      it do
        expect(dependencies).to eq([ [:command, CommandSpec::Cmd, [] ], [ CommandSpec::Cmd, CommandSpec::Cmd, [] ] ])
      end
    end
  end
end