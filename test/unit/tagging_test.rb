require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :taggings, :tags, :booms

  help_testing Tagging, :tag_id => 1, :boom_id => 1

  def test_update_popularity
    boom = booms(:text)
    tag = tags(:cool)
    old_pop = tag.popularity
    tg = Tagging.new(:tag_id => tag.id, :boom_id => boom.id)
    assert tg.save 
    tag.reload
    assert_equal old_pop+1, tag.popularity, "Tag popularity did not increase"
    assert tg.destroy
    tag.reload
    assert_equal old_pop, tag.popularity, "Tag popularity did not descrease"
  end
  
end
