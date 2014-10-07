require 'rake'

module Command
  class Base
    attr_reader :prerequistes
    
    class << self
      def dependencies; @dependencies ||= []; end
      
      def depends key, cls, *attributes
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
    
    def prepare
      self.class.dependencies.each do |d|
        key, cls, attributes = d
        arguments = attributes.map{|a| send(a)}
        result = cls.new(*arguments).perform
        @prerequistes[key] = result if result
      end
    end
  end
end