class Tagging < ActiveRecord::Base
  
  validates_presence_of :boom_id
  validates_presence_of :tag_id

  belongs_to :boom
  belongs_to :tag
    
  protected
  
    def update_count
      self.tag.reload
      self.tag.popularity = self.tag.taggings(true).size
      self.tag.save
    end
    after_save :update_count
    after_destroy :update_count
   
end
