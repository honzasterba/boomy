class CreateBooms < ActiveRecord::Migration
  def self.up
    create_table :booms do |t|
       t.column :link, :text, :null => false
       t.column :title, :string, :null => false
       t.column :created_at, :datetime, :null => false
       t.column :user_id, :integer, :null => false
       t.column :kind, :string, :null => false
       t.column :popularity, :integer, :default => 0, :null => false
   end
   
   add_index :booms, :user_id
   add_index :booms, :created_at
   add_index :booms, :popularity
  end

  def self.down
    drop_table :booms
  end
end
