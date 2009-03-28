require 'uri'

class Boom < ActiveRecord::Base
  
  KINDS = ["video", "image", "sound", "text"]
  KINDS_DESC = ["Video", "Obrázek", "Zvuk", "Text"]
  
  def self.kind_desc(kind)
    KINDS_DESC[KINDS.rindex(kind)]
  end
  
  validates_presence_of :link, :message => "Zadej adresu odkazu."
  validates_presence_of :title, :message => "Zadej nějaký popis."
  validates_presence_of :user_id, :message => "Jen zaregistrovaní mohou přidávat."
  validates_uniqueness_of :link, :message => "Odkaz už existuje."
  
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings, :order => "popularity", :uniq => true

  has_many :points, :dependent => :destroy
  has_many :users, :through => :points, :order => "nick", :uniq => true
  
  belongs_to :user
  
  def validate
    begin
      URI.parse(self.link)
    rescue URI::InvalidURIError => e
      self.errors.add(:link, "Zadej platné URL odkazu.")
    end
  end

  def kind_icon
    "icons/#{kind}.gif"
  end
  
  def kind_desc
    Boom.kind_desc(self.kind)
  end
  
  def has_user(user)
    return false if !user
    @has_user ||= users.rindex(user)
  end
  
  def save_with_tags(tags_str)
    if save
      update_tags(tags_str)
      return true
    else
      return false
    end
  end

  def update_with_tags(attrs, tags_str)
    if update_attributes(attrs)
      update_tags(tags_str)
      return true
    else
      return false
    end
  end

  def tags_str
    self.tags.collect {|tag| tag.name }.join(" ")
  end
  
  def short_link
    return link if link.size < 32
    return link[0, 30] + "..."
  end
  
  def short_title
    return title if title.size < 35
    return title[0, 35].strip + "..."
  end
  
  def slug
    self.title.slugerize
  end  
  
  protected
    
    def update_tags(str)
      return if str.blank?
      new_tags = str.gsub(/,/,"").split(" ").collect {|name| name.strip }
      old_tags = self.tags.collect {|tag| tag.name}
      to_add = new_tags - old_tags
      to_remove = old_tags - new_tags
      to_add.each do |name|
        tag = Tag.find(:first, :conditions => {:name => name})
        tag ||= Tag.create!(:name => name)
        Tagging.create!(:boom => self, :tag => tag)
      end
      to_remove.each do |name|
        tag = Tag.find_by_name(name)
        tagging = Tagging.find(:first, 
          :conditions => {:boom_id => self.id, :tag_id => tag.id})
        tagging.destroy
      end
      tags(true)
    end

end
