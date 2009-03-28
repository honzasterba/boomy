class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :nick, :string, :null => false
      t.column :email, :string, :null => false
      t.column :password, :string, :null => false
    end
    
    add_index :users, :email
  end

  def self.down
    drop_table :users
  end 
end
