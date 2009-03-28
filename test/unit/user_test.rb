require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users
  
  help_testing User, :nick => "Jboss", :password => "honzik", 
    :password_confirmation => "honzik",
    :email => "email@email.com"

end