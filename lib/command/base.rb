require 'rake'

module Command
  class Base
    attr_reader :prerequistes
    
    class << self
      def dependencies; @dependencies ||= []; end
      
      def depends key, *attributes
        if key.is_a?(Class)
          cls = key
        elsif key.is_a?(Symbol)
          cls = attributes.shift
        else
          raise "Unexpected argument type #{key.class}"
        end
        dependencies << [ key, cls, attributes ]
      end
    end
    
    def perform
      @prerequistes = {}
      prepare
      execute
    end
    
    def execute
      raise "Override 'execute' for #{self.class.name}!"
    end
    
    protected

    def dont_clobber file, &block
      require 'pathname'
      homedir = File.absolute_path(ENV['HOME'])
      if File.exists?(file) && %w(home Users).member?(Pathname.new(homedir).parent.basename.to_s)
        $stderr.puts "Your HOME directory is #{homedir}, and I'm afraid to clobber #{file}. Set HOME to something else!"
      else
        yield
      end
    end
    
    def prepare
      self.class.dependencies.each do |d|
        key, cls, attributes = d
        attributes = attributes.clone
        callback = attributes.pop if attributes.last.is_a?(Proc)
        arguments = attributes.map{|a| send(a) }
        result = cls.new(*arguments).perform
        instance_exec(result, &callback) if callback
        @prerequistes[key] = result if result
      end
    end
  end
end