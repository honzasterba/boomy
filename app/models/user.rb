require 'digest/sha1'

class User < ActiveRecord::Base
  
  attr_protected :admin

  validates_presence_of :email, :message => "Zadej email."
  validates_uniqueness_of :email, :message => 'Email už někdo používá.'
  validates_format_of :email, :message => 'Neplatný email.', :with => /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  validates_length_of :password, :within => 6..50, 
    :too_short => "Heslo musí mít alespoň 6 znaků.",
    :too_long => "Heslo je moc dlouhé.",
    :if => :confirm_password?,
    :allow_nil => true
  validates_confirmation_of :password, :message => 'Potvzení hesla se musí shodovat se zadaným heslem.', 
    :if => :confirm_password?
    
  validates_length_of :nick, :minimum => 3, :message => "Přezdívka musí být delší než 3 znaky."
  validates_uniqueness_of :nick, :message => "Přezdívku už někdo používá."
  
  has_many :booms, :order => "created_at DESC"
     
  def self.sha1(phrase)
    Digest::SHA1.hexdigest("--hot stuff-- #{phrase} --sweet salt--")
  end
  
  def deletable?
    booms.empty?
  end

  def confirm_password?
    return true if self.password_confirmation
    return true if new_record?
    return true if self.class.find(self.id).password != self.password
    return false
  end
    
  def slug
    self.nick.slugerize
  end
  
  def anonymous?
    id.nil?
  end
  
  def reset_password!
    new_pass = self.password[0..7]
    self.password = new_pass
    self.save
    new_pass
  end
  
  protected
  
    before_validation_on_update :check_password
    def check_password
      if self.password.blank?
        self.password = nil
        self.password_confirmation = nil
      end
    end
  
    before_create :encrypt_password
    def encrypt_password
      self.password = self.class.sha1(password)
    end
  
    before_update :encrypt_password_unless_empty_or_unchanged
    def encrypt_password_unless_empty_or_unchanged
      user = self.class.find(self.id)
      if self.password.blank?
        self.password = user.password
      elsif self.password != user.password
        encrypt_password
      end
    end  
    
    after_save :clear_pass_confirm
    def clear_pass_confirm
      self.password_confirmation = nil
    end
  
end