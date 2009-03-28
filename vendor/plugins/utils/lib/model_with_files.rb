class ModelWithFiles < ActiveRecord::Base
  include Upload::FileUtils

  self.abstract_class = true

  before_save :prepare_save_files
  before_destroy :prepare_destroy_files
  
  ImagesRootWeb = "/images/upload/"
  
  @@file_attrs = {}
  
  def self.file_attr(map)
    cfg = {:required => true, :name => "file", :desc => "file"}.merge(map)
    self.class_file_attrs << cfg
    meth = "delete_#{cfg[:name]}"
    attr_accessor meth.to_sym
    define_method((meth+"?").to_sym) do
      val = self.send(meth.to_sym)
      (val.to_s == 1.to_s) or (val == true)
    end
  end
  
  def self.class_file_attrs
    @@file_attrs[name] ||= []
    @@file_attrs[name]
  end
  
  def self.file_attrs
    @@file_attrs[name] ||= []
    res = []
    act = self
    while act.respond_to?(:class_file_attrs)
      res.concat act.class_file_attrs
      act = act.superclass
    end
    res
  end
  
  def validate
    # check images were set properly
    if new_record?
      for attr_desc in self.class.file_attrs
        val = self.send(attr_desc[:name])
        if !valid_file_value?(val) and attr_desc[:required]
          errors.add(attr_desc[:name], "Zadej #{attr_desc[:desc]}.")
        elsif val and !valid_file_value(val)
          #errors.add(attr_desc[:name], "Atribut #{attr_desc[:desc]} má neplatnou hodnotu.")
          self.send(attr_desc[:name]+"=", nil)          
        end
      end
    end
    super
  end
  
  def prepare_save_files
    if !new_record?
      prev = self.class.find(id)
    else
      prev = self.class.new
    end
    for attr_desc in self.class.file_attrs
     val = self.send(attr_desc[:name])
     # notify child before save
     self.send(attr_desc[:observe], val) if attr_desc[:observe] and valid_file_value?(val)
     # auto update size attribute
     self.send(attr_desc[:size_attr]+"=", val.size) if attr_desc[:size_attr] and valid_file_value?(val)
     # save file and set attr value
     nval, updated = save_image(val, attr_desc[:name], prev.send(attr_desc[:name]))
     self.send(attr_desc[:name]+"=", nval)
     # notidy child after save
     self.send(attr_desc[:on_new_file]) if updated and attr_desc[:on_new_file]
    end
  end
  private :prepare_save_files
  
  def prepare_destroy_files
    for attr_desc in self.class.file_attrs
      safe_delete(self.send(attr_desc[:name]), logger) if self.send(attr_desc[:name])
    end
  end
  private :prepare_destroy_files
  
  def save_image(file_data, attr_name, prev_value)
    #check input
    if file_data.respond_to?(:to_str) and !file_data.blank? # was already set to some other file path
      return file_data, true
    elsif self.send("delete_#{attr_name}?")
      safe_delete(prev_value, logger) if prev_value
      return nil, false
    elsif !valid_file_value?(file_data)
      return prev_value, false
    else
      #try deleting old file
      safe_delete(prev_value, logger) if prev_value
      name = ImagesRootWeb + create_file_name(file_data)
      return safe_save(name, file_data, logger), true
    end
  end  
  private :save_image
  
  def create_file_name(data)
    if data.original_filename.match(/(.*)\.([^\.]*)/)
      fname, fext = $1, $2
    else
      fname, fext = data.original_filename, "dat"
    end
    fname = fname.slugerize
    fext = fext.slugerize
    hash = Time.now.usec % 814949
    return "#{hash.to_s(16)}_#{fname}.#{fext}"
  end
  private :create_file_name

end