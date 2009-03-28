class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.column :boom_id, :integer
      t.column :tag_id, :integer
    end
    
    add_index :taggings, :tag_id
    add_index :taggings, :boom_id
    add_index :taggings, [:boom_id, :tag_id], :unique => true 
  end

  def self.down
    drop_table :taggings
  end
end
