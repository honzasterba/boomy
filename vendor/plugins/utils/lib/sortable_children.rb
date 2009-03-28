module SortableChildren

  @@sortable_attrs = {}
  
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, SortableChildren::InstanceMethods)
  end  
  
  module ClassMethods
  
    def orderable_collection(name, map)
      map = {:column => "num", :generator => :int}.merge(map)
      #self.class_eval(meth_body(name, map[:column], map[:generator]))
      define_method("move_#{name.to_s}".to_sym) do |op, id|
        move_sortable_item(name, map[:column], map[:generator], op, id)
      end
    end
    
  end
  
  module InstanceMethods 

    def meth_body(name, column, gen)
      str = ""
      str << "def move_#{name.to_s}(op, id)\n"
      str << "move_sortable_item(:#{name.to_s}, :#{column.to_s}, :#{gen.to_s}, op, id) \n"
      str << "end"
      str
    end
    
    def move_sortable_item(collection, column, generator, operation, item_id)
      i = 0
      prev = nil
      data = self.send(collection)
      while i < data.size
        act = data[i]
        if act.id == item_id
          if (:up == operation) and i > 0
            set(act, column, create_number(i-1, data.size, generator))
            set(prev, column, create_number(i, data.size, generator))
            act.save
            prev.save
          elsif (:down == operation) and i < data.size-1
            i = i+1
            set(data[i], column, create_number(i-1, data.size, generator))
            data[i].save
            set(act, column, create_number(i, data.size, generator))
            act.save
          end
        else
          set(act, column, create_number(i, data.size, generator))
          act.save
        end
        prev = act
        i = i + 1
      end
      # refresh data
      self.send(collection, true)
    end
    
    def set(obj, attr, val)
      obj.send(attr+"=", val)
    end
    
    def create_number(num, cnt, gen)
      if gen.to_s == "date"
        create_date_num(num, cnt)
      else
        create_int_num(num)
      end
    end
    
    def create_int_num(num)
      num
    end
    private :create_number
    
    def create_date_num(num, cnt)
      DateTime.new(cnt+1970-num)
    end
    private :create_date_num
    
  end

end

ActiveRecord::Base.send(:include, SortableChildren)