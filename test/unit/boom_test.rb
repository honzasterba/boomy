require File.dirname(__FILE__) + '/../test_helper'

class BoomTest < Test::Unit::TestCase
  fixtures :booms, :users

  help_testing Boom, :user_id => 1, :title => "TITLE", :link => "http://www.link.com/",
    :kind => "video"
    
  def test_create_long_link
    create_boom(:link => "http://www.youtube.com/watch?v=-H7WmR5qF_8&eurl=http%3A%2F%2Ffun%2Ecafetime%2Ecz%2Fvideo%2Fzacatky%2Dsurfingu%2Djsou%2Dtezke%2F")
  end
  
  def test_create_invalid_link
    b = new_boom(:link => "protokol:nze name/url")
    assert !b.valid?
    assert !b.errors.on(:link).empty?
  end

  def test_custom_icon
    b = Boom.new(:kind => "some_custom_kind")
    assert_match(/icons\/some_custom_kind\.gif/, b.kind_icon)
    assert_raise TypeError do ||
      b.kind_desc
    end
  end
  
  def test_has_user
    nick = users(:Nick)
    boom = booms(:text)
    assert !boom.has_user(nick), "User shoul not be present"
    assert Point.create!(:boom_id => boom.id, :user_id => nick.id)
    boom.reload
    assert boom.has_user(nick), "User should be present"
  end
  
end
