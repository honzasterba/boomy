require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  help_testing User, :nick => "john", :email => "john@nekde.cz", :password => "passsword",
    :password_confirmation => "passsword"
  help_testing Boom, :title => "title", :link => "http://www.nekde.com", 
    :kind => "video", :user_id => 1

  def test_no_user
    get :destroy
    assert_redirected_to({:controller => "boom"}, "user is not admin")
  end
  
  def test_no_admin
    u = create_user
    assert u.id, "User not created"
    get :destroy, {}, { :user => u.id }
    assert_redirected_to({:controller => "boom"}, "user is not admin")
  end
  
  def test_admin_can_delete
    u = create_user
    assert u.id, "User not created"
    u.admin = true
    assert u.save, "user was not updated"
    b = create_boom(:user_id => u.id)
    assert b.id, "boom not created"
    get :destroy, {:id => b.id }, {:user => u.id}
    assert_response :redirect
    assert_redirected_to :controller => "boom"
    assert flash[:notice]
  end
  
  def test_form_no_admin
    u = create_user
    b = create_boom(:user_id => u.id)
    get :form, :id => b.id
    assert_response :redirect, "User is not admin"    
  end

end
