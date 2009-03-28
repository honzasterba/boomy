class Point < ActiveRecord::Base

  belongs_to :user
  belongs_to :boom
  
  validates_presence_of :user
  validates_presence_of :boom
  
  validates_uniqueness_of :user_id, :scope => "boom_id"
  
  protected
  
    def update_count
      self.boom.reload
      self.boom.popularity = self.boom.points(true).size
      self.boom.save
    end
    after_save :update_count
    after_destroy :update_count
  
end
