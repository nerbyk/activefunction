module MyDslMethods
  def self.included(base)
    base.extend(ClassMethods)

    # Set up a finalizer for the class
    ObjectSpace.define_finalizer(base, base.method(:finalize_dsl))
  end

  module ClassMethods
    def dsl_method(method_name)
      # Your DSL method implementation here
      puts "DSL method #{method_name} defined in #{self}"
    end

    def finalize_dsl(_id)
      # Finalization logic here
      puts "Finalization logic for #{self}"
    end
  end
end

class A
  include MyDslMethods

  dsl_method :a
end