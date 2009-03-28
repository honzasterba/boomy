class Tag < ActiveRecord::Base

  validates_presence_of :name, :message => "Zadej název tagu."

  has_many :taggings, :dependent => :destroy
  has_many :booms, :through => :taggings, :order => "created_at DESC"
  
  protected
  
    def update_slug
      self.slug = self.name.slugerize
    end
    before_save :update_slug
    
end
