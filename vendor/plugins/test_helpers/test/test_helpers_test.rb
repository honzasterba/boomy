require 'test/unit'
require 'active_support' 
require File.dirname(__FILE__) + '/../lib/test_helpers'
require File.dirname(__FILE__) + '/../lib/test_helpers/model_test_helper' 

class TestHelpersTest < Test::Unit::TestCase

  include TestHelpers::ModelTestHelper

  def test_classmethod_exists
    assert self.class.respond_to?(:help_testing), "This test case does not support ModelTestHelper"
  end
  
  def test_methods_generated
    self.class.send(:help_testing, TestHelpersTest, nil) #this is crazy i know, but why not?
    assert self.respond_to?(:create_test_helpers_test), "Method not found in " + self.class.instance_methods(false).join(", ")
    assert self.respond_to?(:new_test_helpers_test), "Method not found in " + self.class.instance_methods(false).join(", ")
    assert self.respond_to?(:test_ok), "Method not found in " + self.class.instance_methods(false).join(", ")
  end
  
  
end
