module TestHelpers::ModelTestHelper

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    def help_testing(klass, default_args, opts = nil)
       method_ending = klass.name.demodulize.underscore 
       create_method_name = ("create_"+method_ending).to_sym
       new_method_name = ("new_"+method_ending).to_sym
       define_method create_method_name do |*params|
         args = {}
         args = params[0] if params.size > 0 and params[0]
         final_args = default_args.merge(args)
         klass.create!(final_args)
       end
       define_method new_method_name do |*params|
         args = {}
         args = params[0] if params.size > 0 and params[0]
         final_args = default_args.merge(args)
         klass.new(final_args)
       end
       if (!opts or opts[:generate_test])
         define_method :test_ok do
           model = send(create_method_name)
           assert_saved model
        end
      end
    end
  end
  
  module InstanceMethods
  
    def assert_not_saved(object, *reasons)
      reasons ||= []
      reasons.each { |attr|
        assert object.errors.invalid?(attr), "Attribute #{attr} shlould be invalid, " + object.errors.full_messages.join("\n")     
      }
      object.errors.each { |attr, msg|
        assert reasons.index(attr.to_sym), "Attribute #{attr} expected to be valid, " + object.errors.full_messages.join("\n")
      }
      assert !object.valid?, "Object valid while expected to be invalid, " + object.errors.full_messages.join("\n")
      assert object.new_record?, "Object was saved while expected to be invalid, " + object.errors.full_messages.join("\n")
    end
    
    def assert_saved(object)
      assert_valid object
      assert !object.new_record?
    end
    
    
  end
  
end
