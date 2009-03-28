class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.column :boom_id, :integer
      t.column :user_id, :integer
    end
    
    add_index :points, :user_id
    add_index :points, :boom_id
    add_index :points, [:boom_id, :user_id], :unique => true
  end

  def self.down
    drop_table :points
  end
end
