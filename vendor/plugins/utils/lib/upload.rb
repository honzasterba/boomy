module Upload

  # 
  # the base path of all images this library operates on
  # 
  ImagesRootBase = "#{RAILS_ROOT}/public"

  # 
  # Wraps around an external image resizing library
  # supports image resizing for now
  # 
  class PreviewGenerator
  
    class << self
  
      #
      # resizes image into specified dimensions
      # 
      # destination file might not be specified, its name will be created
      # as 'origonal_name_resize.oroginal_extension'
      #
      def resize_image(source, width, height, dest = nil)
        dest ||= default_dest(source, "resize")
        image = MiniMagick::Image.from_file(source)
        image.resize "#{width}x#{height}"
        image.write dest
        dest
      end
      
      #
      # cut the upper left corner of the image with specified dimensions
      # 
      # destination file might not be specified, its name will be created
      # as 'origonal_name_resize.oroginal_extension'
      #    
      def cut_image(source, width, height, dest = nil)
        dest ||= default_dest(source, "cut")
        image = MiniMagick::Image.from_file(source)
        image.crop "#{width}x#{height}+0+0"
        image.write dest
        dest
      end
      
      def default_dest(file, op = "resize")
        if file.match(/(.*)\.([^.]+)/)
          $1 + "_" + op.to_s + "." + $2
        else
          file + "_" + op.to_s
        end
      end
      
      def prepare_source(file)
        ImagesRootBase + file
      end
      
    end
    
  end
  
  # 
  # Usefull methods for handling file operations
  # 
  module FileUtils

    #
    # Atempts to delete the file supplied
    # if the operation is unscuccesfull no error is raied 
    # and the error is logged with logger
    #
    def safe_delete(filename, logger)
      if filename and filename.strip != ""
        begin
          File.delete(ImagesRootBase + filename)
        rescue 
          logger.warn("Couldnt delete file #{filename} because of #{$!}.")
        end
      end
    end
    
    # 
    # Atempts to save the file supplied
    # if the operation is unscuccesfull no error is raied 
    # and the error is logged with logger
    # 
    def safe_save(name, data, loggger)
      begin
        File.open(ImagesRootBase + name, "wb") { |f| f.write(data.read) }
        return name
      rescue
        logger.error("Failed to save uploaded file because: " + $!)
        return nil
      end
    end

    # 
    # returns true if the file is of valid binary type and has lengh more than zero 
    #
    def valid_file_value?(val)
      valid_file_value(val) and (val.size > 0)
    end
    
    # 
    # returns true if the file is of valid binary type and not nil
    # 
    def valid_file_value(val)
      !val.nil? and (val.kind_of? StringIO or val.kind_of? Tempfile)
    end
    
    # 
    # encodes the file name with unique hash at the beggining
    # 
    def create_file_name(name)
      if name.match(/(.*)\.([^\.]*)/)
        fname, fext = $1, $2
      else
        fname, fext = name, "dat"
      end
      fname = fname.slugerize
      fext = fext.slugerize
      hash = Time.now.usec % 814949
      return "#{hash.to_s(16)}_#{fname}.#{fext}"
    end
    
  
  end
end