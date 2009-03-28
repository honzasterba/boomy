class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string
      t.column :slug, :string
      t.column :popularity, :integer
    end
    
    add_index :tags, :popularity 
  end

  def self.down
    drop_table :tags
  end
end
