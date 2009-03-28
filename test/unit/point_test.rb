require File.dirname(__FILE__) + '/../test_helper'

class PointTest < Test::Unit::TestCase
  fixtures :points, :users, :booms
  
  help_testing Point, :user_id => 1, :boom_id => 1

  def test_update_popularity
    boom = booms(:text)
    user = users(:Nick)
    old_pop = boom.popularity
    point = Point.new(:user_id => user.id, :boom_id => boom.id)
    assert point.save 
    boom.reload
    assert_equal old_pop+1, boom.popularity, "Boom popularity did not increase"
    assert point.destroy
    boom.reload
    assert_equal old_pop, boom.popularity, "Boom popularity did not descrease"
  end
end
