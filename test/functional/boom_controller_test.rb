require File.dirname(__FILE__) + '/../test_helper'
require 'boom_controller'
require 'boom'

# Re-raise errors caught by the controller.
class BoomController; def rescue_action(e) raise e end; end

class BoomControllerTest < Test::Unit::TestCase
  def setup
    @controller = BoomController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @user = create_user
  end

  help_testing User, { :nick => "john", :email => "john@nekde.cz", :password => "passsword",
    :password_confirmation => "passsword" }, :generate_test => false
  help_testing Boom, { :title => "TITLE", :link => "http://www.link.com/",
                     :kind => "video" }, :generate_test => false
                     
  def test_index
    do_test_simple_action(:index)
  end
  
  def test_novinky
    do_test_simple_action(:novinky)
  end
  
  def test_novinky_rss
    Boom.destroy_all
    assert create_boom(:user_id => @user.id)
    get :novinky, {:format => "rss"}
    assert_response :success
  end
  
  def test_best_of
    do_test_simple_action(:best_of)
  end
  
  def test_about
    get :o_projektu
    assert_response :success
  end
  
  def test_show_add_no_login
    get :add
    assert_response :redirect
    assert_redirected_to :action => "login"
  end
  
  def test_show_add
    get :add, {}, {:user => @user.id}
    assert_response :success
  end
  
  def test_show_add_from_bookmarklet
    get :add, {:title => "TITLE", :link => "http://www.test.com/path"}, {:user => @user.id}
    assert_response :success
    boom = assigns(:boom)
    assert boom
    assert_equal "TITLE", boom.title
    assert_equal "http://www.test.com/path", boom.link
    assert boom.errors.empty?
  end
  
  def test_add_submit
    post :add, {:boom => {:title => "title", :link => "http://www.test.com/path", :kind => "video"}, 
      :tags => "test, tag, něco"}, {:user => @user.id}
    assert_response :redirect
    assert_redirected_to :action => "novinky"
    assert flash[:notice]
  end
  
  def test_add_to_point_from_bookmarklet
    boom = create_boom(:user_id => @user)
    get :add, {:title => "some title", :link => boom.link}, {:user => @user.id}
    assert_response :redirect
    assert_redirected_to :action => "detail", :id => boom
  end
  
  def test_add_to_point
    boom = create_boom(:user_id => @user)
    post :add, {:boom => {:title => "title", :link => boom.link}, 
      :tags => "test, tag, něco"}, {:user => @user.id}
    assert_response :redirect
    assert_redirected_to :action => "detail", :id => boom
  end
  
  
  def test_detail
    boom = create_boom(:user_id => @user.id)
    get :detail, {:id => boom.id}
    assert_response :success
  end
  
  def test_rate_redirects_not_loged_in
    get :rate, {:id => 1}
    assert_response :redirect
    assert_redirected_to :action => "login"
  end
  
  def test_voting
    boom = create_boom(:user_id => @user.id)
    get :rate, {:id => boom.id}, {:user => @user.id}
    assert_response :redirect
    boom.reload
    assert_equal 1, boom.popularity, "Popularity should be increased."
    assert_redirected_to :action => "detail", :id => boom.id
    #try the same vote again
    get :rate, {:id => boom.id}, {:user => @user.id}
    assert_response :redirect
    assert_redirected_to :action => "detail", :id => boom.id
    boom.reload
    assert_equal 1, boom.popularity, "Popularity should stay the same."
  end
  
  def test_change_pass_get
    get :change_pass, {}, {:user => @user.id}
    assert_response :success
  end

  def test_change_pass_ok
    get :change_pass, {:password => "nove_heslo", :password_confirmation => "nove_heslo"}, {:user => @user.id}
    assert_response :redirect
    @user.reload
    assert @user.password == User.sha1("nove_heslo")
  end
  
  def test_change_pass_diff
    get :change_pass, {:password => "nove_heslo", :password_confirmation => "nove_heslo2"}, {:user => @user.id}
    assert_response :redirect
    @user.reload
    assert @user.password != User.sha1("nove_heslo")    
  end
  
  protected
    def do_test_simple_action(name)
      get :index
      assert_response :success
      get :index, :page => 2
      assert_response :success
    end  
  
end
